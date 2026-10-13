import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import auth  # noqa: E402


def test_six_character_password_can_be_hashed_and_verified():
    password = "123456"

    password_hash = auth.get_password_hash(password)

    assert password_hash != password
    assert auth.verify_password(password, password_hash)
    assert not auth.verify_password("654321", password_hash)
