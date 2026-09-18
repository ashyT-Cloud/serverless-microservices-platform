# AWS Production Serverless Microservices Platform

## 1. Project Overview

This project implements a production-style serverless microservices
platform on AWS using an event-driven architecture.

The platform is designed around independently deployable microservices
that communicate through synchronous APIs and asynchronous events.

## 2. Goals

- Build a serverless microservices architecture on AWS
- Demonstrate event-driven communication
- Implement asynchronous processing
- Demonstrate reliable message processing
- Implement retries and dead-letter queues
- Apply IAM least-privilege principles
- Implement infrastructure using Terraform
- Implement CI/CD using GitHub Actions
- Implement centralized observability using CloudWatch

## 3. High-Level Architecture

Client
  |
  v
API Gateway
  |
  +-------------------+
  |                   |
  v                   v
User Service      Workout Service
Lambda             Lambda
  |                   |
  v                   v
Users Table       Workouts Table
                      |
                      | WorkoutCreated
                      v
                 EventBridge
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
     Analytics   Notification    SQS
      Service      Service        Queue
       Lambda       Lambda          |
                                    v
                               Worker Lambda
                                    |
                                    v
                                DynamoDB

CloudWatch provides centralized logging, metrics, and alarms.

## 4. Microservices

### User Service

Responsible for user-related operations.

Responsibilities:

- Create users
- Retrieve users
- Update users

Owns:

- User data

Interface:

- API Gateway

Events:

- UserCreated

### Workout Service

Responsible for workout operations.

Responsibilities:

- Create workouts
- Retrieve workouts
- Retrieve workouts for a user

Owns:

- Workout data

Interface:

- API Gateway

Events:

- WorkoutCreated

### Analytics Service

Responsible for processing workout-related events and maintaining
analytics information.

Communication:

- EventBridge

Consumes:

- WorkoutCreated

Owns:

- Analytics data

### Notification Service

Responsible for processing notification-related events.

Communication:

- EventBridge

Consumes:

- WorkoutCreated
- UserCreated

### Worker Service

Responsible for asynchronous background processing.

Communication:

- SQS

Responsibilities:

- Consume messages
- Process messages
- Handle failures
- Support retry behavior

## 5. Communication Patterns

### Synchronous Communication

External client requests use:

Client -> API Gateway -> Lambda

This is used when an immediate response is required.

### Asynchronous Communication

Internal services use:

Service -> EventBridge -> Consumer

This reduces direct coupling between services.

## 6. Event-Driven Architecture

The Workout Service publishes a WorkoutCreated event after successfully
creating a workout.

EventBridge routes the event to the appropriate consumers.

Example:

WorkoutCreated
    |
    +--> Analytics Service
    |
    +--> Notification Service
    |
    +--> SQS Worker Queue

## 7. Data Ownership

Each microservice owns its own data.

Services must not directly modify another service's database.

Initial data stores:

- User Service -> DynamoDB
- Workout Service -> DynamoDB
- Analytics Service -> DynamoDB
- Worker Service -> DynamoDB/S3 where required

## 8. Reliability

The platform will implement:

- SQS retries
- Dead-letter queues
- Visibility timeouts
- Idempotent processing
- Failure isolation
- CloudWatch alarms

## 9. Security

Security controls will include:

- IAM roles
- Least-privilege policies
- Encryption at rest
- Secure configuration
- No long-lived AWS credentials on the workstation
- Dedicated execution roles for Lambda functions

## 10. Infrastructure as Code

All AWS infrastructure will be managed using Terraform.

Terraform environments:

- dev
- prod

Reusable infrastructure will be implemented through Terraform modules.

## 11. CI/CD

GitHub Actions will be used for:

- Terraform formatting
- Terraform validation
- Terraform plan
- Terraform deployment
- Lambda deployment
- Automated verification

## 12. Observability

CloudWatch will provide:

- Lambda logs
- API Gateway logs
- Metrics
- Alarms
- Error monitoring

## 13. Future Enhancements

Potential future enhancements include:

- Lambda versions and aliases
- EventBridge archive and replay
- API throttling
- Distributed tracing
- Advanced event schema validation
- Automated rollback
