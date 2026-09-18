# Workout Service

Serverless microservice responsible for workout operations.

## Runtime

- Python 3.12
- AWS Lambda
- Amazon DynamoDB
- Amazon API Gateway

## API

- `GET /workouts`
- `POST /workouts`
- `GET /workouts/{workoutId}`

## Responsibilities

- Create workouts
- Retrieve workouts
- Own the workout data
- Publish workout events for downstream services
