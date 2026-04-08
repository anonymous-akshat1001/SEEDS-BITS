# ai_analysis.py
# AI-powered session log analysis using Google Gemini API
# Allows teachers to ask natural-language questions about session activity

import os
import json
from datetime import datetime
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import models
from session_logger import get_session_logs

import cohere

COHERE_API_KEY = os.getenv("COHERE_API_KEY")


# System prompt that instructs Gemini on how to analyze session logs
SYSTEM_PROMPT = """You are an intelligent analytics assistant for the SEEDS educational platform. 
You analyze session activity logs from classroom sessions where a teacher plays audio content 
and students participate by listening, chatting, raising hands, and interacting.

You will be given structured session log data and a teacher's question. 
Analyze the logs carefully and provide clear, actionable insights.

Guidelines:
- Be concise and specific in your answers
- Use student names when referring to participants
- If asked about participation, consider: chat messages sent, hand raises, time spent in session, mute/unmute activity
- If data is insufficient to answer, say so honestly
- Format your response in a readable way (use bullet points, numbers, etc.)
- Focus on educational insights that help the teacher understand student engagement
"""


async def get_enriched_session_logs(db: AsyncSession, session_id: int) -> dict:
    """
    Fetch all session logs and enrich them with user names and session info.
    Returns a structured dict ready to be formatted as context for the AI.
    """
    # Get session info
    session = await db.get(models.Session, session_id)
    if not session:
        return None
    
    # Get creator name
    creator = await db.get(models.User, session.created_by) if session.created_by else None
    
    # Get all logs (up to 1000)
    logs = await get_session_logs(db, session_id, limit=1000)
    
    # Build a cache of user_id -> name
    user_ids = set()
    for log in logs:
        if log.user_id:
            user_ids.add(log.user_id)
    
    user_names = {}
    for uid in user_ids:
        user = await db.get(models.User, uid)
        if user:
            user_names[uid] = user.name
    
    # Get participant info
    q = await db.execute(
        select(models.Participant).filter(models.Participant.session_id == session_id)
    )
    participants = q.scalars().all()
    
    participant_info = []
    for p in participants:
        name = user_names.get(p.user_id, f"User#{p.user_id}")
        participant_info.append({
            "participant_id": p.participant_id,
            "user_id": p.user_id,
            "name": name,
            "joined_at": p.joined_at.isoformat() if p.joined_at else None,
            "left_at": p.left_at.isoformat() if p.left_at else None,
            "is_muted": p.is_muted,
            "is_kicked": p.is_kicked,
            "hand_raised": p.hand_raised,
        })
    
    # Format logs with user names
    formatted_logs = []
    for log in logs:
        user_name = user_names.get(log.user_id, f"User#{log.user_id}") if log.user_id else "System"
        formatted_logs.append({
            "event_type": log.event_type,
            "user": user_name,
            "user_id": log.user_id,
            "details": log.event_details,
            "timestamp": log.created_at.isoformat() if log.created_at else None,
        })
    
    return {
        "session_id": session_id,
        "title": session.title,
        "created_by": creator.name if creator else "Unknown",
        "is_active": session.is_active,
        "created_at": session.created_at.isoformat() if session.created_at else None,
        "ended_at": session.ended_at.isoformat() if session.ended_at else None,
        "participants": participant_info,
        "total_log_events": len(formatted_logs),
        "logs": formatted_logs,
    }


def format_logs_as_context(enriched_data: dict) -> str:
    """Convert enriched log data into a readable text block for the AI prompt."""
    lines = []
    lines.append(f"=== SESSION INFO ===")
    lines.append(f"Session ID: {enriched_data['session_id']}")
    lines.append(f"Title: {enriched_data['title']}")
    lines.append(f"Created by: {enriched_data['created_by']}")
    lines.append(f"Status: {'Active' if enriched_data['is_active'] else 'Ended'}")
    lines.append(f"Started: {enriched_data['created_at']}")
    if enriched_data['ended_at']:
        lines.append(f"Ended: {enriched_data['ended_at']}")
    
    lines.append(f"\n=== PARTICIPANTS ({len(enriched_data['participants'])}) ===")
    for p in enriched_data['participants']:
        status_parts = []
        if p['is_kicked']:
            status_parts.append("KICKED")
        if p['is_muted']:
            status_parts.append("MUTED")
        if p['hand_raised']:
            status_parts.append("HAND RAISED")
        if p['left_at']:
            status_parts.append(f"left at {p['left_at']}")
        status = ", ".join(status_parts) if status_parts else "active"
        lines.append(f"  - {p['name']} (user_id={p['user_id']}, joined={p['joined_at']}, status={status})")
    
    lines.append(f"\n=== ACTIVITY LOG ({enriched_data['total_log_events']} events) ===")
    for log in enriched_data['logs']:
        detail_str = ""
        if log['details']:
            # Extract key details, skip redundant fields
            important = {k: v for k, v in log['details'].items() 
                        if k not in ('participant_id',) and v is not None}
            if important:
                detail_str = f" | {json.dumps(important)}"
        lines.append(f"  [{log['timestamp']}] {log['event_type']} by {log['user']}{detail_str}")
    
    return "\n".join(lines)


async def ask_ai_about_session(
    db: AsyncSession,
    session_id: int,
    question: str
) -> dict:
    """
    Main function: fetch session logs, send to Gemini with the question, return AI answer.
    """
    if not COHERE_API_KEY:
        raise ValueError("COHERE_API_KEY not found in environment variables. Get a free key from https://dashboard.cohere.com/")
    
    # Create Cohere client
    co = cohere.ClientV2(COHERE_API_KEY)
    
    # Fetch and enrich logs
    enriched = await get_enriched_session_logs(db, session_id)
    if enriched is None:
        raise ValueError(f"Session {session_id} not found")
    
    # Format log data as readable text
    context = format_logs_as_context(enriched)
    
    # Build the prompt
    user_prompt = f"""Here is the session log data:

{context}

---

Teacher's Question: {question}

Please analyze the session data above and answer the teacher's question. Be specific and use student names."""

    # Call Cohere V2
    response = co.chat(
        model="command-a-03-2025",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt}
        ]
    )
    
    # Extract answer text from V2 response structure
    answer_text = response.message.content[0].text
    
    return {
        "session_id": session_id,
        "question": question,
        "answer": answer_text,
        "log_count": enriched["total_log_events"],
    }


import torch
from transformers import pipeline

local_llm_pipeline = None

def _get_local_llm():
    global local_llm_pipeline
    if local_llm_pipeline is None:
        print("\n⏳ Loading Local LLM (this will take a moment the first time)...")
        # Use appropriate dtype to save memory
        local_llm_pipeline = pipeline(
            "text-generation", 
            model="Qwen/Qwen2.5-0.5B-Instruct", 
            device_map="auto",
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32
        )
        print("✅ Local LLM loaded successfully!\n")
    return local_llm_pipeline

async def ask_local_ai_about_session(
    db: AsyncSession,
    session_id: int,
    question: str
) -> dict:
    """
    Fetch session logs, send to local huggingface model, return AI answer.
    """
    enriched = await get_enriched_session_logs(db, session_id)
    if enriched is None:
        raise ValueError(f"Session {session_id} not found")
    
    context = format_logs_as_context(enriched)
    
    user_prompt = f"Here is the session log data:\n\n{context}\n\n---\n\nTeacher's Question: {question}\n\nPlease analyze the session data above and answer the teacher's question. Be concise and use student names."

    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user_prompt}
    ]
    
    llm = _get_local_llm()
    
    outputs = llm(messages, max_new_tokens=400, temperature=0.7)
    
    generated = outputs[0]["generated_text"]
    if isinstance(generated, list):
        answer_text = generated[-1]["content"]
    else:
        answer_text = str(generated)
        
    return {
        "session_id": session_id,
        "question": question,
        "answer": answer_text,
        "log_count": enriched["total_log_events"],
    }
