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


SYSTEM_PROMPT = """You are an intelligent, professional analytics and teaching assistant for the SEEDS educational platform.
You support the teacher not only by analyzing classroom session logs, but also by answering general questions, providing advice, or engaging in normal conversation.

Operating Guidelines:
1. Intent Recognition: First, privately understand the nature of the teacher's input.
   - If it is casual conversation, a greeting, or a general question, respond naturally and professionally WITHOUT attempting to force an answer from the session logs.
   - If it is a question specifically concerning the classroom session, student activity, or events, use the provided [SESSION LOG DATA] to answer.
2. Direct Response: DO NOT explain your internal reasoning or classification. Simply output the final answer or conversational reply directly.
3. Data Retrieval: When using the Session Logs, be precise and objective. Rely strictly on the data provided and use student names when referencing participation.
4. Missing Data: If the teacher asks about session details that cannot be found in the provided logs, clearly state that the information is not available in the current data.
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
        print("\nLoading Local LLM (this will take a moment the first time)...")
        local_llm_pipeline = pipeline(
            "text-generation", 
            model="Qwen/Qwen2.5-1.5B-Instruct", 
            device_map="auto",
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32
        )
        print("Local LLM loaded successfully!\n")
    return local_llm_pipeline

def preload_local_llm():
    """Called at server startup to preload the model into RAM/VRAM."""
    try:
        _get_local_llm()
    except Exception as e:
        print(f"Failed to preload LLM: {e}")

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
    
    user_prompt = f"""[SESSION LOG DATA START]
{context}
[SESSION LOG DATA END]

Teacher's Input: {question}"""

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
