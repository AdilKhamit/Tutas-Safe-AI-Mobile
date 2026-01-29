"""
API Routes for AI Chat Assistant
"""
import logging
from datetime import datetime, timedelta
import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.api.deps import get_db
from app.core.config import settings
from app.schemas.chat import ChatMessage, ChatResponse, ChatContext
from app.models.pipes import Pipe
from app.models.defects import Defect
from app.models.inspections import Inspection

logger = logging.getLogger(__name__)

router = APIRouter()

# LLM Configuration - используем локальную Llama через Ollama
OLLAMA_API_URL = settings.OLLAMA_API_URL
LLM_MODEL = settings.LLM_MODEL


async def get_chat_context(db: AsyncSession) -> ChatContext:
    """Get context data from database for AI responses"""
    # Total pipes
    pipes_stmt = select(func.count(Pipe.id))
    pipes_result = await db.execute(pipes_stmt)
    total_pipes = pipes_result.scalar() or 0
    
    # Total defects
    defects_stmt = select(func.count(Defect.id))
    defects_result = await db.execute(defects_stmt)
    total_defects = defects_result.scalar() or 0
    
    # Critical defects (severity >= 4)
    critical_stmt = select(func.count(Defect.id)).where(Defect.severity_level >= 4)
    critical_result = await db.execute(critical_stmt)
    critical_defects = critical_result.scalar() or 0
    
    # Recent inspections (last 30 days)
    recent_date = datetime.utcnow() - timedelta(days=30)
    inspections_stmt = select(func.count(Inspection.id)).where(
        Inspection.completed_date >= recent_date
    )
    inspections_result = await db.execute(inspections_stmt)
    recent_inspections = inspections_result.scalar() or 0
    
    # Calculate integrity index (simplified)
    integrity_index = 1.0 - (critical_defects / max(total_defects, 1)) * 0.1
    integrity_index = max(0.0, min(1.0, integrity_index))
    
    return ChatContext(
        total_pipes=total_pipes,
        total_defects=total_defects,
        critical_defects=critical_defects,
        recent_inspections=recent_inspections,
        integrity_index=round(integrity_index, 3),
    )


async def call_llm_api(user_message: str, context: ChatContext) -> str:
    """Call local Llama model via Ollama API"""
    # System prompt with context
    system_prompt = f"""You are Tutas AI Integrity Assistant, an expert in pipeline monitoring and integrity management.

Current System Status:
- Total Pipes: {context.total_pipes}
- Total Defects: {context.total_defects}
- Critical Defects: {context.critical_defects}
- Recent Inspections (30 days): {context.recent_inspections}
- Integrity Index: {context.integrity_index * 100:.1f}%

You help users with:
- Pipeline integrity analysis
- Risk assessment
- Inspection reports
- Compliance status
- Defect analysis
- Segment-specific queries

Provide clear, professional, and helpful responses in Russian or English based on user's language. If asked about specific data, use the context provided above."""

    # Combine system prompt and user message for Ollama
    full_prompt = f"""{system_prompt}

User question: {user_message}

Assistant response:"""

    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            # Ollama uses /api/generate endpoint with different format
            response = await client.post(
                OLLAMA_API_URL,
                json={
                    "model": LLM_MODEL,
                    "prompt": full_prompt,
                    "stream": False,  # Get complete response at once
                    "options": {
                        "temperature": 0.7,
                        "num_predict": 500,  # Max tokens
                    },
                },
            )
            response.raise_for_status()
            data = response.json()
            
            # Ollama returns response in "response" field
            if "response" in data:
                return data["response"].strip()
            else:
                logger.warning(f"Unexpected Ollama response format: {data}")
                return generate_fallback_response(user_message, context)
                
    except httpx.ConnectError:
        logger.error(f"Cannot connect to Ollama at {OLLAMA_API_URL}. Make sure Ollama is running.")
        return generate_fallback_response(user_message, context)
    except httpx.TimeoutException:
        logger.error(f"Ollama request timeout")
        return generate_fallback_response(user_message, context)
    except Exception as e:
        logger.error(f"LLM API error: {str(e)}")
        return generate_fallback_response(user_message, context)


def generate_fallback_response(user_message: str, context: ChatContext) -> str:
    """Generate fallback response when LLM API is not available"""
    message_lower = user_message.lower()
    
    if any(word in message_lower for word in ["critical", "anomaly", "risk", "urgent"]):
        return f"""I found {context.critical_defects} critical defects in the pipeline network that require immediate attention.

Based on the current data:
- Total defects: {context.total_defects}
- Critical defects: {context.critical_defects}
- Integrity Index: {context.integrity_index * 100:.1f}%

I recommend reviewing the critical defects and scheduling immediate inspections for affected segments."""

    elif any(word in message_lower for word in ["inspection", "report", "status"]):
        return f"""Based on the latest inspection data:

- Total Inspections (last 30 days): {context.recent_inspections}
- Integrity Index: {context.integrity_index * 100:.1f}%
- Total Defects: {context.total_defects}
- Critical Defects: {context.critical_defects}

The pipeline network is {'operating within acceptable parameters' if context.integrity_index > 0.9 else 'requires attention'}."""

    elif any(word in message_lower for word in ["compliance", "regulation", "standard"]):
        compliance_status = "100% - ALL REGULATIONS MET" if context.integrity_index > 0.95 else "REQUIRES REVIEW"
        return f"""Compliance Status: {compliance_status}

- Integrity Index: {context.integrity_index * 100:.1f}%
- Critical Defects: {context.critical_defects}
- Total Pipes: {context.total_pipes}

{'All pipeline segments are within regulatory requirements.' if context.integrity_index > 0.95 else 'Some segments may require review to ensure full compliance.'}"""

    elif any(word in message_lower for word in ["segment", "pipe", "asset"]):
        return f"""I can help you analyze specific segments. Here's the overview:

- Total Pipes: {context.total_pipes}
- Active Defects: {context.total_defects}
- Critical Issues: {context.critical_defects}

Please provide the segment ID, QR code, or pipe identifier for detailed analysis."""

    else:
        return f"""I'm Tutas AI Integrity Assistant. I can help you with:

• Pipeline integrity analysis
• Risk assessment and critical defects
• Inspection reports and status
• Compliance monitoring
• Segment-specific queries

Current System Overview:
- Total Pipes: {context.total_pipes}
- Integrity Index: {context.integrity_index * 100:.1f}%
- Critical Defects: {context.critical_defects}

What would you like to know?"""


@router.post("/chat", response_model=ChatResponse, status_code=status.HTTP_200_OK)
async def chat_with_ai(
    message: ChatMessage,
    db: AsyncSession = Depends(get_db),
) -> ChatResponse:
    """
    Chat with AI Assistant about pipeline integrity.
    
    Args:
        message: User message and optional conversation ID
        db: Database session
        
    Returns:
        AI response with optional summary card
    """
    logger.info(f"Chat request: {message.message[:50]}...")
    
    # Get context from database
    context = await get_chat_context(db)
    
    # Call LLM API
    ai_response = await call_llm_api(message.message, context)
    
    # Generate summary card if response contains critical information
    summary_card = None
    if context.critical_defects > 0 and any(
        word in message.message.lower() 
        for word in ["critical", "anomaly", "risk"]
    ):
        summary_card = {
            "priority": "CRITICAL",
            "critical_defects": context.critical_defects,
            "total_defects": context.total_defects,
            "integrity_index": round(context.integrity_index * 100, 1),
        }
    
    conversation_id = message.conversation_id or f"conv_{hash(message.message) % 1000000}"
    
    logger.info(f"Chat response generated for conversation: {conversation_id}")
    
    return ChatResponse(
        response=ai_response,
        conversation_id=conversation_id,
        summary_card=summary_card,
        timestamp=datetime.utcnow(),
    )
