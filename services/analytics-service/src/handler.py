import os

import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")

table = dynamodb.Table(os.environ["ANALYTICS_TABLE"])
processed_events = dynamodb.Table(os.environ["IDEMPOTENCY_TABLE"])


def lambda_handler(event, context):
    event_id = event.get("id")
    detail = event.get("detail", {})

    if not event_id:
        raise ValueError("Event ID is required")

    user_id = detail.get("userId")
    workout_type = detail.get("workoutType")
    duration = detail.get("durationMinutes")

    if not user_id or not workout_type or duration is None:
        raise ValueError("Invalid WorkoutCreated event")

    # Idempotency check.
    try:
        processed_events.put_item(
            Item={
                "eventId": event_id
            },
            ConditionExpression="attribute_not_exists(eventId)"
        )
    except ClientError as error:
        if error.response["Error"]["Code"] == "ConditionalCheckFailedException":
            return {
                "status": "duplicate",
                "eventId": event_id
            }
        raise

    # Update aggregate counters.
    table.update_item(
        Key={"userId": user_id},
        UpdateExpression=(
            "ADD totalWorkouts :one, "
            "totalDurationMinutes :duration"
        ),
        ExpressionAttributeValues={
            ":one": 1,
            ":duration": int(duration)
        }
    )

    # Ensure workoutTypes map exists.
    table.update_item(
        Key={"userId": user_id},
        UpdateExpression="SET workoutTypes = if_not_exists(workoutTypes, :empty)",
        ExpressionAttributeValues={
            ":empty": {}
        }
    )

    # Increment workout type.
    table.update_item(
        Key={"userId": user_id},
        UpdateExpression=(
            "SET #types.#workoutType = "
            "if_not_exists(#types.#workoutType, :zero) + :one"
        ),
        ExpressionAttributeNames={
            "#types": "workoutTypes",
            "#workoutType": workout_type
        },
        ExpressionAttributeValues={
            ":zero": 0,
            ":one": 1
        }
    )

    return {
        "status": "processed",
        "eventId": event_id,
        "userId": user_id,
        "workoutType": workout_type
    }
