from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager

from models import CmdRequest
from serial_manager import SerialManager

mgr = SerialManager()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    # mgr.add_device("light_controller", "/dev/ttyACM0", baud=115200)
    print("Serial devices initialized")

    yield

    # Shutdown
    for dev_id in list(mgr.devices.keys()):
        mgr.remove_device(dev_id)
    print("Serial devices closed")


app = FastAPI(lifespan=lifespan)

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/arduino/devices")
def devices():
    return {"ok": True, "devices": [d.__dict__ for d in mgr.list_devices()]}

@app.post("/arduino/rescan")
def rescan():
    return {"ok": True}

@app.post("/arduino/{device_id}/cmd")
async def cmd(device_id: str, req: CmdRequest):
    try:
        resp = await mgr.send(device_id, req.cmd, req.data)

        return {"ok": True, "data": resp}

    except KeyError as e:
        raise HTTPException(status_code=404, detail=str(e))

    except TimeoutError as e:
        return JSONResponse(
            status_code=504,
            content={"ok": False, "error": str(e)},
        )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"ok": False, "error": str(e)},
        )