import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    for record in event.get("Records", []):
        message = json.loads(record["body"])

        logger.info(
            "Notification Worker received event: %s",
            json.dumps(message)
        )

        detail = message.get("detail", {})

        user_id = detail.get("userId")
        workout_type = detail.get("workoutType")

        if not user_id or not workout_type:
            raise ValueError("Invalid notification event")

        logger.info(
            "Notification processed for user=%s workout=%s",
            user_id,
            workout_type
        )

    return {
        "status": "processed",
        "records": len(event.get("Records", []))
    }
