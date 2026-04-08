import sys
import os
import asyncio
from datetime import datetime, timedelta
import random

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from database import AsyncSessionLocal
import models
from sqlalchemy import select

async def main():
    print("⏳ Connecting to database to simulate 2 new distinct sessions...")
    
    async with AsyncSessionLocal() as db:
        # Get existing teacher 
        res = await db.execute(select(models.User).filter(models.User.role == "teacher"))
        teacher = res.scalars().first()
        
        # Get existing students
        res = await db.execute(select(models.User).filter(models.User.role == "student"))
        students = res.scalars().all()
        
        if not teacher or not students:
            print("❌ No teacher or students found! Please run 'python3 demo_suite.py' first.")
            return

        # ==========================================
        # SESSION A: Highly Interactive & Chaotic
        # ==========================================
        base_time_1 = datetime.utcnow() - timedelta(days=1, hours=2)
        print("\n🚀 Simulating Session A: 'Introduction to Deep Learning' (Highly Interactive)...")
        session_a = models.Session(title="Introduction to Deep Learning", created_by=teacher.user_id, is_active=False, created_at=base_time_1, ended_at=base_time_1 + timedelta(hours=1))
        db.add(session_a)
        await db.commit()
        await db.refresh(session_a)
        
        s_id_a = session_a.session_id
        
        # Teacher and students join
        db.add(models.Participant(session_id=s_id_a, user_id=teacher.user_id, joined_at=base_time_1))
        db.add(models.Log(session_id=s_id_a, user_id=teacher.user_id, event_type="join", created_at=base_time_1))
        
        for s in students:
            join_time = base_time_1 + timedelta(minutes=random.randint(1, 5))
            db.add(models.Participant(session_id=s_id_a, user_id=s.user_id, joined_at=join_time))
            db.add(models.Log(session_id=s_id_a, user_id=s.user_id, event_type="join", created_at=join_time))

        events_a = []
        events_a.append((teacher.user_id, "chat", {"message": "Welcome to Deep Learning! Today we cover Neural Networks."}, base_time_1 + timedelta(minutes=6)))
        
        # Student 4 is super confused and asks many questions
        stu_4 = students[3].user_id
        events_a.append((stu_4, "hand_raise", {}, base_time_1 + timedelta(minutes=12)))
        events_a.append((stu_4, "chat", {"message": "I don't understand backpropagation. Can you repeat?"}, base_time_1 + timedelta(minutes=13)))
        events_a.append((teacher.user_id, "chat", {"message": "Sure! It's how the network learns from its errors by updating weights."}, base_time_1 + timedelta(minutes=15)))
        
        # Student 9 keeps muting and unmuting (noisy background)
        stu_9 = students[8].user_id
        for m in range(20, 35, 3):
            events_a.append((stu_9, "unmute", {}, base_time_1 + timedelta(minutes=m)))
            events_a.append((stu_9, "mute", {}, base_time_1 + timedelta(minutes=m, seconds=10)))
        events_a.append((teacher.user_id, "chat", {"message": "Student 09, please keep your microphone muted, we hear background noise."}, base_time_1 + timedelta(minutes=36)))
        
        # Student 2 drops out due to bad internet and rejoins later
        stu_2 = students[1].user_id
        events_a.append((stu_2, "leave", {}, base_time_1 + timedelta(minutes=40)))
        events_a.append((stu_2, "join", {}, base_time_1 + timedelta(minutes=45)))
        events_a.append((stu_2, "chat", {"message": "Sorry, my wifi dropped out!"}, base_time_1 + timedelta(minutes=46)))
        
        for e in events_a:
            db.add(models.Log(session_id=s_id_a, user_id=e[0], event_type=e[1], event_details=e[2], created_at=e[3]))

        for s in students:
            db.add(models.Log(session_id=s_id_a, user_id=s.user_id, event_type="leave", created_at=session_a.ended_at))
        db.add(models.Log(session_id=s_id_a, user_id=teacher.user_id, event_type="leave", created_at=session_a.ended_at))


        # ==========================================
        # SESSION B: Very Quiet / Passive
        # ==========================================
        base_time_2 = datetime.utcnow() - timedelta(hours=3)
        print("🚀 Simulating Session B: 'Midterm Exam Review' (Very Quiet, Low Engagement)...")
        session_b = models.Session(title="Midterm Exam Review", created_by=teacher.user_id, is_active=False, created_at=base_time_2, ended_at=base_time_2 + timedelta(hours=1))
        db.add(session_b)
        await db.commit()
        await db.refresh(session_b)
        
        s_id_b = session_b.session_id
        
        # Teacher and only 5 students join (Low attendance)
        db.add(models.Participant(session_id=s_id_b, user_id=teacher.user_id, joined_at=base_time_2))
        db.add(models.Log(session_id=s_id_b, user_id=teacher.user_id, event_type="join", created_at=base_time_2))
        
        present_students = students[:5]
        for s in present_students:
            db.add(models.Participant(session_id=s_id_b, user_id=s.user_id, joined_at=base_time_2 + timedelta(minutes=random.randint(1, 5))))
            db.add(models.Log(session_id=s_id_b, user_id=s.user_id, event_type="join", created_at=base_time_2 + timedelta(minutes=random.randint(1, 5))))

        events_b = []
        events_b.append((teacher.user_id, "chat", {"message": "Welcome to the review. Does anyone have any questions?"}, base_time_2 + timedelta(minutes=10)))
        events_b.append((teacher.user_id, "chat", {"message": "Anyone? It's completely silent..."}, base_time_2 + timedelta(minutes=15)))
        
        # Just one response
        stu_1 = present_students[0].user_id
        events_b.append((stu_1, "chat", {"message": "No questions, everything is clear."}, base_time_2 + timedelta(minutes=16)))
        
        events_b.append((teacher.user_id, "audio_play", {"file": "review_recording.mp3"}, base_time_2 + timedelta(minutes=20)))
        
        for e in events_b:
            db.add(models.Log(session_id=s_id_b, user_id=e[0], event_type=e[1], event_details=e[2], created_at=e[3]))

        for s in present_students:
            db.add(models.Log(session_id=s_id_b, user_id=s.user_id, event_type="leave", created_at=session_b.ended_at))
        db.add(models.Log(session_id=s_id_b, user_id=teacher.user_id, event_type="leave", created_at=session_b.ended_at))

        await db.commit()
        
        print(f"\n✅ Created Session A (Interactive) -> Session ID: {s_id_a}")
        print(f"✅ Created Session B (Quiet)       -> Session ID: {s_id_b}")
        print(f"Teacher User ID: {teacher.user_id}")
        print("\nAll done! You can now query the AI about either session.")

if __name__ == "__main__":
    asyncio.run(main())
