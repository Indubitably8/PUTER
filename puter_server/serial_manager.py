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

        # Arduino often resets on open
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
        self.remove_device(device_id)

        dev = SerialDevice(device_id, port, baud)
        self.devices[device_id] = dev
        self.device_info[device_id] = DeviceInfo(id=device_id, port=port, online=True, baud=baud)

        fw = await self._probe_fw(device_id)
        self.device_info[device_id].fw = fw

    def remove_device(self, device_id: str):
        old = self.devices.pop(device_id, None)
        if old:
            old.close()
        self.device_info.pop(device_id, None)

    def list_devices(self):
        return list(self.device_info.values())

    async def rescan(self):
        for dev_id, dev in self.devices.items():
            info = self.device_info.get(dev_id)
            try:
                dev.reopen()
                if info:
                    info.online = True
                    info.fw = await self._probe_fw(dev_id)
            except Exception:
                if info:
                    info.online = False
                    info.fw = None

    async def send(self, device_id: str, cmd: str, data: Dict[str, Any]) -> Dict[str, Any]:
        dev = self.devices.get(device_id)
        if not dev:
            raise KeyError(f"Unknown device: {device_id}")

        info = self.device_info.get(device_id)
        if info and not info.online:
            try:
                dev.reopen()
                info.online = True
                info.fw = await self._probe_fw(device_id)
            except Exception:
                pass

        return await dev.request(cmd, data)
