import asyncio
import json
from httpx import AsyncClient

async def get_test():
    # Attempt to login as test teacher and check audio list
    async with AsyncClient(base_url="http://localhost:8000") as client:
        # Assuming we can't easily login, let's just query the DB directly
        import sys
        import os
        sys.path.append(os.path.abspath('backend'))
        
        from database import SessionLocal
        from models import AudioFile
        from sqlalchemy import select
        
        async with SessionLocal() as db:
            q = await db.execute(select(AudioFile).order_by(AudioFile.uploaded_at.desc()))
            files = q.scalars().all()
            for f in files:
                print(f"ID: {f.audio_id}, Title: {f.title}, UploadedBy: {f.uploaded_by}")
            if not files:
                print("No audio files in database!")

if __name__ == "__main__":
    asyncio.run(get_test())
