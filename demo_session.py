import requests
import sys

base_url = "http://localhost:8000"

def create_demo():
    print("Registering Teacher...")
    t_res = requests.post(f"{base_url}/auth/register", json={
        "name": "Demo Teacher",
        "phone_number": "5555555555",
        "password": "password123",
        "role": "teacher"
    })
    
    if t_res.status_code == 400 and "already registered" in t_res.text.lower():
        t_login = requests.post(f"{base_url}/auth/login", data={
            "username": "5555555555",
            "password": "password123"
        })
        try:
            t_uid = t_login.json()["user_id"]
        except KeyError:
            print("Failed to login teacher", t_login.json())
            return
    else:
        try:
            t_uid = t_res.json()["user_id"]
        except KeyError:
            print("Failed to register teacher:", t_res.text)
            return
            
    print(f"Teacher ID: {t_uid} (Phone: 5555555555, Pass: password123)")

    print("Registering Student...")
    s_res = requests.post(f"{base_url}/auth/register", json={
        "name": "Demo Student",
        "phone_number": "4444444444",
        "password": "password123",
        "role": "student"
    })
    
    if s_res.status_code == 400 and "already registered" in s_res.text.lower():
        s_login = requests.post(f"{base_url}/auth/login", data={
            "username": "4444444444",
            "password": "password123"
        })
        try:
            s_uid = s_login.json()["user_id"]
        except:
            print("Failed to login student")
            return
    else:
        try:
            s_uid = s_res.json()["user_id"]
        except:
            print("Failed to register student:", s_res.text)
            return
            
    print(f"Student ID: {s_uid} (Phone: 4444444444, Pass: password123)")

    print("Creating Session...")
    sess_res = requests.post(f"{base_url}/sessions?user_id={t_uid}", json={
        "title": "Interactive Demo Session"
    })
    if sess_res.status_code != 200:
        print("Failed to create session:", sess_res.text)
        return
        
    session_id = sess_res.json()["session_id"]
    print(f"Session ID: {session_id}")

    print(f"Student Joining Session {session_id}...")
    join_res = requests.post(f"{base_url}/sessions/{session_id}/join?user_id={s_uid}", data={"user_id": s_uid})
    print(f"Join Response: {join_res.text}")
        
    try:
        participant_id = join_res.json()["participant_id"]
        print(f"Participant ID: {participant_id}")
    except:
        print("Participant join failed.")
        return

    import time
    time.sleep(1)

    print("Creating chat logs...")
    chat_res = requests.post(f"{base_url}/sessions/{session_id}/action?user_id={s_uid}", json={
        "type": "chat",
        "text": "Hello! I am ready for the lecture."
    })
    print(chat_res.text)
    
    time.sleep(1)
    print("Muting participant...")
    mute_res = requests.post(f"{base_url}/sessions/{session_id}/action?user_id={t_uid}", json={
        "type": "mute_participant",
        "target_participant_id": participant_id,
        "mute": True
    })
    print(mute_res.text)
    
    time.sleep(1)
    print("Student raising hand...")
    raise_res = requests.post(f"{base_url}/sessions/{session_id}/action?user_id={s_uid}", json={
        "type": "raise_hand"
    })
    print(raise_res.text)

    print("Done generating logs!")

if __name__ == "__main__":
    create_demo()
