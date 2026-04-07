import requests

print('Fetching /audio/list for teacher (user_id=2)')
try:
    r = requests.get('http://127.0.0.1:8000/audio/list?user_id=2')
    print(r.status_code)
    print(r.json()[:2])
except Exception as e:
    print(e)

print('Fetching /audio/list for student (user_id=4)')
try:
    r = requests.get('http://127.0.0.1:8000/audio/list?user_id=4')
    print(r.status_code)
    print(r.json()[:2])
except Exception as e:
    print(e)
