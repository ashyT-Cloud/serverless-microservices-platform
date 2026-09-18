import json
import os
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["USERS_TABLE"])


def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }


def lambda_handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method")
    path_parameters = event.get("pathParameters") or {}

    if method == "GET" and not path_parameters.get("userId"):
        return response(200, {
            "service": "user-service",
            "message": "User Service is running"
        })

    if method == "POST":
        body = json.loads(event.get("body") or "{}")

        if not body.get("name") or not body.get("email"):
            return response(400, {
                "message": "name and email are required"
            })

        user_id = str(uuid.uuid4())

        user = {
            "userId": user_id,
            "name": body["name"],
            "email": body["email"],
            "createdAt": datetime.now(timezone.utc).isoformat()
        }

        table.put_item(Item=user)

        return response(201, user)

    if method == "GET" and path_parameters.get("userId"):
        result = table.get_item(
            Key={"userId": path_parameters["userId"]}
        )

        user = result.get("Item")

        if not user:
            return response(404, {
                "message": "User not found"
            })

        return response(200, user)

    return response(404, {
        "message": "Route not found"
    })
