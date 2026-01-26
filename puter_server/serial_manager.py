import asyncio
import json
from dataclasses import dataclass
from typing import Dict, Optional, Any

import serial

@dataclass
class DeviceInfo:
    id: str
    port: str
    online: bool = True
    type: Optional[str] = None
    fw: Optional[str] = None

class SerialDevice:
    def __init__(self, device_id: str, port: str, baud: int = 115200):
        self.id = device_id
        self.port = port
        self.baud = baud
        self._ser = serial.Serial(port, baudrate=baud, timeout=0.2)
        self._lock = asyncio.Lock()

    def close(self):
        try:
            self._ser.close()
        except Exception:
            pass

    async def request(self, cmd: str, data: Dict[str, Any], timeout: float = 1.5) -> Dict[str, Any]:
        packet = {"cmd": cmd, "data": data}
        line = (json.dumps(packet) + "\n").encode("utf-8")

        async with self._lock:
            self._ser.write(line)
            self._ser.flush()

            deadline = asyncio.get_event_loop().time() + timeout
            buf = b""

            while asyncio.get_event_loop().time() < deadline:
                await asyncio.sleep(0.01)
                chunk = self._ser.readline()
                if not chunk:
                    continue
                buf = chunk.strip()
                if not buf:
                    continue

                try:
                    return json.loads(buf.decode("utf-8"))
                except Exception:
                    continue

            raise TimeoutError("Timed out waiting for device response")

class SerialManager:
    def __init__(self):
        self.devices: Dict[str, SerialDevice] = {}
        self.device_info: Dict[str, DeviceInfo] = {}

    def add_device(self, device_id: str, port: str, baud: int = 115200):
        self.remove_device(device_id)
        dev = SerialDevice(device_id, port, baud)
        self.devices[device_id] = dev
        self.device_info[device_id] = DeviceInfo(id=device_id, port=port, online=True)

    def remove_device(self, device_id: str):
        old = self.devices.pop(device_id, None)
        if old:
            old.close()
        self.device_info.pop(device_id, None)

    def list_devices(self):
        return list(self.device_info.values())

    async def send(self, device_id: str, cmd: str, data: Dict[str, Any]) -> Dict[str, Any]:
        dev = self.devices.get(device_id)
        if not dev:
            raise KeyError(f"Unknown device: {device_id}")
        return await dev.request(cmd, data)