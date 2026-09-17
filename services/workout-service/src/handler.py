import json
import os
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["WORKOUTS_TABLE"])


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

    # Health check
    if method == "GET" and not path_parameters.get("workoutId"):
        return response(200, {
            "service": "workout-service",
            "message": "Workout Service is running"
        })

    # Create workout
    if method == "POST":
        body = json.loads(event.get("body") or "{}")

        required_fields = [
            "userId",
            "workoutType",
            "durationMinutes"
        ]

        if not all(body.get(field) for field in required_fields):
            return response(400, {
                "message": "userId, workoutType and durationMinutes are required"
            })

        workout_id = str(uuid.uuid4())

        workout = {
            "workoutId": workout_id,
            "userId": body["userId"],
            "workoutType": body["workoutType"],
            "durationMinutes": body["durationMinutes"],
            "createdAt": datetime.now(timezone.utc).isoformat()
        }

        table.put_item(Item=workout)

        return response(201, workout)

    # Get workout
    if method == "GET" and path_parameters.get("workoutId"):
        result = table.get_item(
            Key={
                "workoutId": path_parameters["workoutId"]
            }
        )

        workout = result.get("Item")

        if not workout:
            return response(404, {
                "message": "Workout not found"
            })

        return response(200, workout)

    return response(404, {
        "message": "Route not found"
    })
