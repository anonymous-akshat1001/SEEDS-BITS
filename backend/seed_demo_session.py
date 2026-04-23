import sys
import os
import asyncio
from datetime import datetime, timedelta
import random

# Add backend to path so we can import models
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from database import AsyncSessionLocal
import models

async def main():
    print("🎓 Generating a realistic SEEDS-BITS classroom session...")
    print("⏳ Please wait, simulating 35+ interactions...")
    
    async with AsyncSessionLocal() as db:
        # Create a teacher
        teacher = models.User(name="Prof. Alan Turing", phone_number=f"555{random.randint(1000,9999)}", role="teacher", password_hash="dummy")
        db.add(teacher)
        
        # Create 10 students
        students = []
        for i in range(1, 11):
            student = models.User(name=f"Student {i}", phone_number=f"555{random.randint(1000,9999)}", role="student", password_hash="dummy")
            db.add(student)
            students.append(student)
            
        await db.commit()
        await db.refresh(teacher)
        for s in students:
            await db.refresh(s)
            
        # Create a Session
        base_time = datetime.utcnow() - timedelta(hours=2)
        end_time = base_time + timedelta(hours=1)
        session = models.Session(title="Advanced AI Ethics Lecture", created_by=teacher.user_id, is_active=False, created_at=base_time, ended_at=end_time)
        db.add(session)
        await db.commit()
        await db.refresh(session)
        
        session_id = session.session_id
        
        # Add participants and logs
        db.add(models.Participant(session_id=session_id, user_id=teacher.user_id, joined_at=base_time))
        db.add(models.Log(session_id=session_id, user_id=teacher.user_id, event_type="join", created_at=base_time))
        
        # Students join over 5 minutes
        for s in students:
            join_time = base_time + timedelta(seconds=random.randint(10, 300))
            db.add(models.Participant(session_id=session_id, user_id=s.user_id, joined_at=join_time))
            db.add(models.Log(session_id=session_id, user_id=s.user_id, event_type="join", created_at=join_time))
            
        # Class activities
        events = []
        
        # T: 10 mins
        events.append((teacher.user_id, "audio_play", {"file": "intro.mp3"}, base_time + timedelta(minutes=10)))
        
        # T: 15 mins - Student 3 is very active
        events.append((students[2].user_id, "hand_raise", {}, base_time + timedelta(minutes=15)))
        events.append((students[2].user_id, "unmute", {}, base_time + timedelta(minutes=15, seconds=30)))
        events.append((students[2].user_id, "chat", {"message": "Wait, what exactly is the difference between bias and variance?"}, base_time + timedelta(minutes=16)))
        events.append((students[2].user_id, "mute", {}, base_time + timedelta(minutes=17)))
        
        # T: 20 mins
        events.append((teacher.user_id, "chat", {"message": "Excellent question Student 3! Bias is error from wrong assumptions. Variance is sensitivity to small fluctuations."}, base_time + timedelta(minutes=20)))
        
        # T: 25 mins - Student 7 drops connection
        events.append((students[6].user_id, "leave", {}, base_time + timedelta(minutes=25)))
        
        # T: 30 mins - Group chat
        for i in [1, 3, 8, 9]:
            msgs = ["Makes sense!", "Got it", "Interesting", "Thanks Prof!"]
            events.append((students[i].user_id, "chat", {"message": msgs[random.randint(0, 3)]}, base_time + timedelta(minutes=30, seconds=random.randint(0, 60))))
            
        # T: 40 mins
        events.append((students[2].user_id, "chat", {"message": "But what if the dataset itself is historically biased?"}, base_time + timedelta(minutes=40)))
        events.append((students[8].user_id, "chat", {"message": "I agree with Student 3."}, base_time + timedelta(minutes=45)))
        
        # T: 50 mins
        events.append((teacher.user_id, "chat", {"message": "Good point. We will cover dataset mitigation next week! Class dismissed."}, base_time + timedelta(minutes=50)))
        
        for e in events:
            db.add(models.Log(session_id=session_id, user_id=e[0], event_type=e[1], event_details=e[2], created_at=e[3]))
            
        # End session
        for s in students:
            if s.user_id != students[6].user_id: # 7 already left
                db.add(models.Log(session_id=session_id, user_id=s.user_id, event_type="leave", created_at=session.ended_at))
        db.add(models.Log(session_id=session_id, user_id=teacher.user_id, event_type="leave", created_at=session.ended_at))
        
        await db.commit()
    
    print("\n✅ Demo Session Created Successfully in the Database!")
    print(f"📌 Session ID: {session_id}")
    print(f"📌 Teacher User ID: {teacher.user_id}")
    print("\n🚀================ HOW TO DEMO THIS LIVE ================🚀")
    print("1. Ensure your backend server is running (uvicorn main:app --reload)")
    print("2. Open Google Chrome and navigate to: http://localhost:8000/docs")
    print("3. Scroll to the green 'POST /sessions/{session_id}/ai/ask' endpoint.")
    print("4. Click the 'Try it out' button on the top right of the section.")
    print(f"5. Enter '{session_id}' in the 'session_id' path field.")
    print(f"6. Enter '{teacher.user_id}' in the 'user_id' query field.")
    print('7. In the Request body placeholder, paste this exact text:')
    print('   {')
    print('       "question": "Give a 2 sentence summary. Who was the most active and did anyone leave early?"')
    print('   }')
    print("8. Click the large blue 'Execute' button!")
    print("9. Watch the AI instantly reply with a perfect analysis of the students. 🎤")
    print("=================================================================\n")

if __name__ == "__main__":
    asyncio.run(main())
