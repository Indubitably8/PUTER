import os
import signal
import asyncio
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from models import CmdRequest
from serial_manager import SerialManager

mgr = SerialManager()

_scan_task: asyncio.Task | None = None


async def _scan_loop():
    while True:
        try:
            await mgr.scan()
        except Exception:
            pass
        await asyncio.sleep(5)


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _scan_task

    # Startup
    try:
        await mgr.add_device("light_controller", "/dev/ttyUSB0", baud=115200)
        print("Serial devices initialized")
    except Exception as e:
        print(f"WARNING: Failed to init serial device: {e}")

    _scan_task = asyncio.create_task(_scan_loop())

    yield
    if _scan_task and not _scan_task.done():
        _scan_task.cancel()
        try:
            await _scan_task
        except asyncio.CancelledError:
            pass

    for dev_id in list(mgr.device_info.keys()):
        await mgr.remove_device(dev_id)

    print("Serial devices closed")


app = FastAPI(lifespan=lifespan)


@app.get("/health")
def health():
    return {"ok": True}


@app.get("/arduino/devices")
def devices():
    return {"ok": True, "devices": [d.__dict__ for d in mgr.list_devices()]}


# Manual trigger (optional)
@app.post("/arduino/scan")
async def scan():
    try:
        await mgr.scan()
        return {"ok": True, "devices": [d.__dict__ for d in mgr.list_devices()]}
    except Exception as e:
        return JSONResponse(status_code=500, content={"ok": False, "error": str(e)})


@app.post("/arduino/{device_id}/cmd")
async def cmd(device_id: str, req: CmdRequest):
    try:
        resp = await mgr.send(device_id, req.cmd, req.data)
        return {"ok": True, "data": resp}

    except KeyError as e:
        raise HTTPException(status_code=404, detail=str(e))

    except TimeoutError as e:
        return JSONResponse(status_code=504, content={"ok": False, "error": str(e)})

    except Exception as e:
        return JSONResponse(status_code=500, content={"ok": False, "error": str(e)})


@app.post("/shutdown")
async def shutdown():
    os.kill(os.getpid(), signal.SIGTERM)
    return {"ok": True}