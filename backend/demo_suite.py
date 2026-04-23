import sys
import os
import asyncio
from datetime import datetime, timedelta
import random

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from database import engine, AsyncSessionLocal
import models
from auth import get_password_hash

async def reset_db():
    print("🧹 Wiping all previous database data...")
    async with engine.begin() as conn:
        await conn.run_sync(models.Base.metadata.drop_all)
        await conn.run_sync(models.Base.metadata.create_all)
    print("✨ Database reset complete!")

async def main():
    await reset_db()
    
    print("\n🎓 Generating Users (1 Teacher, 10 Students)...")
    
    async with AsyncSessionLocal() as db:
        # Create Teacher
        teacher_phone = "5550000"
        teacher_pass = "teacher123"
        teacher = models.User(name="TEACHER1", phone_number=teacher_phone, role="teacher", password_hash=get_password_hash(teacher_pass))
        db.add(teacher)
        
        # Create Students
        students = []
        for i in range(1, 11):
            student_phone = f"55500{i:02d}"
            student_pass = f"student{i:02d}"
            student = models.User(name=f"Student {i:02d}", phone_number=student_phone, role="student", password_hash=get_password_hash(student_pass))
            db.add(student)
            students.append(student)
            
        await db.commit()
        await db.refresh(teacher)
        for s in students:
            await db.refresh(s)
            
        print("\n📊 Generated Credentials:")
        print("| Role | Name | Username (Phone) | Password |")
        print("|------|------|------------------|----------|")
        print(f"| Teacher | **{teacher.name}** | `{teacher_phone}` | `{teacher_pass}` |")
        for s, phone, pwd in zip(students, [f"55500{i:02d}" for i in range(1,11)], [f"student{i:02d}" for i in range(1,11)]):
            print(f"| Student | {s.name} | `{phone}` | `{pwd}` |")
            
        print("\n⏳ Simulating realistic Math Lecture interactions...")
        
        # Create Session
        base_time = datetime.utcnow() - timedelta(hours=2)
        end_time = base_time + timedelta(hours=1)
        session = models.Session(title="Calculus 101: Chain Rule and Integration", created_by=teacher.user_id, is_active=True, created_at=base_time, ended_at=end_time)
        db.add(session)
        await db.commit()
        await db.refresh(session)
        
        session_id = session.session_id
        
        # Teacher Joins
        db.add(models.Participant(session_id=session_id, user_id=teacher.user_id, joined_at=base_time))
        db.add(models.Log(session_id=session_id, user_id=teacher.user_id, event_type="join", created_at=base_time))
        
        # Students Join (Staggered over 5 minutes)
        for s in students:
            join_time = base_time + timedelta(seconds=random.randint(10, 300))
            db.add(models.Participant(session_id=session_id, user_id=s.user_id, joined_at=join_time))
            db.add(models.Log(session_id=session_id, user_id=s.user_id, event_type="join", created_at=join_time))
            
        # ==========================================
        # EVENT LOGGING (EVERY POSSIBLE TYPE)
        # ==========================================
        events = []
        
        # Teacher plays an introductory audio/video
        events.append((teacher.user_id, "audio_play", {"file": "intro_to_calculus.mp3"}, base_time + timedelta(minutes=5)))
        
        # Student 3 raises hand for a question
        events.append((students[2].user_id, "hand_raise", {}, base_time + timedelta(minutes=12)))
        events.append((students[2].user_id, "unmute", {}, base_time + timedelta(minutes=12, seconds=30)))
        events.append((students[2].user_id, "chat", {"message": "TEACHER1, how do we apply the chain rule when there's a square root involved?"}, base_time + timedelta(minutes=13)))
        
        # Teacher answers
        events.append((teacher.user_id, "chat", {"message": "Excellent question Student 03! First, convert the square root to a fractional power of 1/2, then apply the power rule followed by the chain rule inside."}, base_time + timedelta(minutes=15)))
        events.append((students[2].user_id, "mute", {}, base_time + timedelta(minutes=16)))
        
        # Disruptive Student (Student 9)
        events.append((students[8].user_id, "unmute", {}, base_time + timedelta(minutes=20)))
        events.append((students[8].user_id, "chat", {"message": "*Loud dog barking and music playing in the background*"}, base_time + timedelta(minutes=21)))
        
        # Teacher warns and then kicks Student 9
        events.append((teacher.user_id, "chat", {"message": "Please mute your microphone, Student 09. This is a lecture."}, base_time + timedelta(minutes=22)))
        events.append((teacher.user_id, "kick", {"reason": "Disruptive background noise", "target_user_id": students[8].user_id}, base_time + timedelta(minutes=23)))
        events.append((students[8].user_id, "leave", {}, base_time + timedelta(minutes=23))) 
        
        # Passive / Group interactions in chat
        for i in [0, 4, 5, 7]:
            msgs = ["I understand now, thanks TEACHER1!", "Integration by parts is still confusing.", "The visuals on the slide really helped.", "Yes, makes sense."]
            events.append((students[i].user_id, "chat", {"message": msgs[random.randint(0, 3)]}, base_time + timedelta(minutes=30, seconds=random.randint(0, 60))))
            
        # Wrapping up
        events.append((teacher.user_id, "chat", {"message": "That's all for today. Please review the homework on limits!"}, base_time + timedelta(minutes=50)))
        
        # Insert events sorted chronologically
        events.sort(key=lambda x: x[3])
        for e in events:
            db.add(models.Log(session_id=session_id, user_id=e[0], event_type=e[1], event_details=e[2], created_at=e[3]))
            
        # Everyone leaves
        for s in students:
            if s.user_id != students[8].user_id: # Student 9 was already kicked
                db.add(models.Log(session_id=session_id, user_id=s.user_id, event_type="leave", created_at=session.ended_at))
        db.add(models.Log(session_id=session_id, user_id=teacher.user_id, event_type="leave", created_at=session.ended_at))
        
        await db.commit()
    
    print("\n✅ New Math Demo Session Created Successfully!")
    print(f"📌 Session ID: {session_id}")
    print(f"📌 Teacher User ID: {teacher.user_id}")
    print("\n🚀================ HOW TO TEST THE AI ENDPOINT ================🚀")
    print("\nRun this command in a new terminal to query the AI:")
    print(f"""curl -s -X POST "http://localhost:8000/sessions/{session_id}/ai/ask?user_id={teacher.user_id}" -H "Content-Type: application/json" -d '{{"question": "Summarize the math lecture. Mention who asked questions and if anyone was disruptive."}}' | python3 -m json.tool""")
    print("\n=================================================================\n")

if __name__ == "__main__":
    asyncio.run(main())
