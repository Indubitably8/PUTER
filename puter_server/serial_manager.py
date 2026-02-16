import asyncio
import json
import time
from dataclasses import dataclass
from typing import Dict, Optional, Any

import serial


@dataclass
class DeviceInfo:
    id: str
    port: str
    online: bool = True
    fw: Optional[str] = None
    baud: int = 115200


class SerialDevice:
    def __init__(self, device_id: str, port: str, baud: int = 115200):
        self.id = device_id
        self.port = port
        self.baud = baud

        self._ser = serial.Serial(port, baudrate=baud, timeout=0.2)

        time.sleep(1.8)
        try:
            self._ser.reset_input_buffer()
            self._ser.reset_output_buffer()
        except Exception:
            pass

        self._lock = asyncio.Lock()

    def close(self):
        try:
            self._ser.close()
        except Exception:
            pass

    def reopen(self):
        self.close()
        self._ser = serial.Serial(self.port, baudrate=self.baud, timeout=0.2)

        time.sleep(1.8)
        try:
            self._ser.reset_input_buffer()
            self._ser.reset_output_buffer()
        except Exception:
            pass

    def _read_one_json_line(self, timeout: float) -> Dict[str, Any]:
        deadline = time.monotonic() + timeout

        while time.monotonic() < deadline:
            raw = self._ser.readline()
            if not raw:
                continue

            raw = raw.strip()
            if not raw:
                continue

            try:
                return json.loads(raw.decode("utf-8"))
            except Exception:
                continue

        raise TimeoutError("Timed out waiting for device response")

    async def request(self, cmd: str, data: Dict[str, Any], timeout: float = 1.5) -> Dict[str, Any]:
        packet = {"cmd": cmd, "data": data}
        line = (json.dumps(packet, separators=(",", ":")) + "\n").encode("utf-8")

        async with self._lock:
            try:
                self._ser.reset_input_buffer()
            except Exception:
                pass

            self._ser.write(line)
            self._ser.flush()

            return await asyncio.to_thread(self._read_one_json_line, timeout)


class SerialManager:
    def __init__(self):
        self.devices: Dict[str, SerialDevice] = {}
        self.device_info: Dict[str, DeviceInfo] = {}

        self._connect_tasks: Dict[str, asyncio.Task] = {}
        self._lock = asyncio.Lock()
        self._scan_lock = asyncio.Lock()

    async def _probe_fw(self, device_id: str, timeout: float = 1.0) -> Optional[str]:
        dev = self.devices.get(device_id)
        if not dev:
            return None
        try:
            resp = await dev.request("info", {}, timeout=timeout)
            if isinstance(resp, dict) and resp.get("ok") is True:
                data = resp.get("data")
                if isinstance(data, dict):
                    fw = data.get("fw")
                    if isinstance(fw, str):
                        return fw
        except Exception:
            pass
        return None

    async def add_device(self, device_id: str, port: str, baud: int = 115200):
        await self.remove_device(device_id)

        self.device_info[device_id] = DeviceInfo(
            id=device_id,
            port=port,
            baud=baud,
            online=False,
            fw=None,
        )

        self._start_connect(device_id)

    async def remove_device(self, device_id: str):
        t = self._connect_tasks.pop(device_id, None)
        if t and not t.done():
            t.cancel()

        async with self._lock:
            dev = self.devices.pop(device_id, None)

        if dev:
            dev.close()

        self.device_info.pop(device_id, None)

    def list_devices(self):
        return list(self.device_info.values())

    def _start_connect(self, device_id: str):
        t = self._connect_tasks.get(device_id)
        if t and not t.done():
            return
        self._connect_tasks[device_id] = asyncio.create_task(self._connect(device_id))

    async def _connect(self, device_id: str):
        info = self.device_info.get(device_id)
        if not info:
            return

        async with self._lock:
            if device_id in self.devices:
                return

        try:
            dev = await asyncio.to_thread(SerialDevice, info.id, info.port, info.baud)
        except Exception:
            info.online = False
            info.fw = None
            return

        async with self._lock:
            if device_id not in self.device_info:
                dev.close()
                return
            self.devices[device_id] = dev

        fw = await self._probe_fw(device_id, timeout=1.0)
        if fw is None:
            async with self._lock:
                dead = self.devices.pop(device_id, None)
            if dead:
                dead.close()
            info.online = False
            info.fw = None
            return

        info.online = True
        info.fw = fw

    async def scan(self):
        if self._scan_lock.locked():
            return

        async with self._scan_lock:
            for device_id, info in list(self.device_info.items()):
                async with self._lock:
                    dev = self.devices.get(device_id)

                if dev is None:
                    info.online = False
                    info.fw = None
                    self._start_connect(device_id)
                    continue

                try:
                    fw = await self._probe_fw(device_id)

                    if fw is None:
                        raise RuntimeError("Probe failed")

                    info.online = True
                    info.fw = fw

                except Exception:
                    info.online = False
                    info.fw = None

                    async with self._lock:
                        dead = self.devices.pop(device_id, None)
                    if dead:
                        dead.close()

    async def send(self, device_id: str, cmd: str, data: Dict[str, Any]) -> Dict[str, Any]:
        dev = self.devices.get(device_id)
        if not dev:
            if device_id in self.device_info:
                self._start_connect(device_id)
            raise KeyError(f"Device not connected: {device_id}")

        return await dev.request(cmd, data)
