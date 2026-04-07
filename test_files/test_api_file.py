import requests
import json

try:
    with open('test_api_output.txt', 'w') as f:
        f.write('Fetching /audio/list for student (user_id=4)\n')
        r = requests.get('http://127.0.0.1:8000/audio/list?user_id=4')
        f.write(str(r.status_code) + '\n')
        if r.status_code == 200:
            f.write(json.dumps(r.json()[:2], indent=2))
        else:
            f.write(r.text)
except Exception as e:
    with open('test_api_output.txt', 'w') as f:
        f.write(str(e))
