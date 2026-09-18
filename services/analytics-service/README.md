# Analytics Service

Event-driven serverless microservice responsible for workout analytics.

## Runtime

- Python 3.12
- AWS Lambda
- Amazon DynamoDB
- Amazon EventBridge

## Input Event

`WorkoutCreated`

## Responsibilities

- Consume workout-created events
- Maintain per-user workout statistics
- Own analytics data
