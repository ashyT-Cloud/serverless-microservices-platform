import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))

from handler import lambda_handler


def test_lambda_handler():
    response = lambda_handler({}, {})

    assert response["statusCode"] == 200

    body = json.loads(response["body"])

    assert body["service"] == "user-service"
    assert body["message"] == "User Service is running"
