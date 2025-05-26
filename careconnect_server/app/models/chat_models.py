# careconnect_server/app/models/chat_models.py
from pydantic import BaseModel
from typing import List, Literal

class ChatMessage(BaseModel):
    role: Literal["user", "model"]
    content: str

class UserInput(BaseModel):
    query: str
    history: List[ChatMessage] = []

class ClientResponse(BaseModel):
    type: Literal["content", "error", "info"]
    data: str