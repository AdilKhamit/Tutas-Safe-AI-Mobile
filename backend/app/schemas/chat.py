"""
Chat schemas for AI Assistant
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class ChatMessage(BaseModel):
    """Chat message from user"""
    message: str
    conversation_id: Optional[str] = None


class ChatResponse(BaseModel):
    """AI Assistant response"""
    response: str
    conversation_id: str
    summary_card: Optional[dict] = None
    timestamp: datetime


class ChatContext(BaseModel):
    """Context data for AI responses"""
    total_pipes: int
    total_defects: int
    critical_defects: int
    recent_inspections: int
    integrity_index: float
