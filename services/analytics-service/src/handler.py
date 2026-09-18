import os

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["ANALYTICS_TABLE"])


def lambda_handler(event, context):
    detail = event.get("detail", {})

    user_id = detail.get("userId")
    workout_type = detail.get("workoutType")
    duration = detail.get("durationMinutes")

    if not user_id or not workout_type or duration is None:
        raise ValueError("Invalid WorkoutCreated event")

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

    # Maintain per-workout-type counter separately.
    table.update_item(
        Key={"userId": user_id},
        UpdateExpression="SET workoutTypes = if_not_exists(workoutTypes, :empty)",
        ExpressionAttributeValues={
            ":empty": {}
        }
    )

    table.update_item(
        Key={"userId": user_id},
        UpdateExpression="SET #types.#workoutType = if_not_exists(#types.#workoutType, :zero) + :one",
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
        "userId": user_id,
        "workoutType": workout_type
    }
