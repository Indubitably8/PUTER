from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()
state = {"throttle": 0.0}

class Throttle(BaseModel):
    value: float

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/servo/state")
def servo_state():
    return state

@app.post("/servo/throttle")
def set_throttle(t: Throttle):
    v = max(-1.0, min(1.0, float(t.value)))
    state["throttle"] = v
    print("throttle =", v)
    return {"ok": True, "value": v}

@app.post("/servo/stop")
def stop():
    state["throttle"] = 0.0
    print("stop")
    return {"ok": True}