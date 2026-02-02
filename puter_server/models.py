from pydantic import BaseModel, Field
from typing import Any, Dict


class CmdRequest(BaseModel):
    cmd: str
    data: Dict[str, Any] = Field(default_factory=dict)


class ApiOk(BaseModel):
    ok: bool = True
    data: Dict[str, Any] = Field(default_factory=dict)


class ApiErr(BaseModel):
    ok: bool = False
    error: str
