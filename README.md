# ☁️ AWS Production Serverless Microservices Platform

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Serverless-orange?style=for-the-badge&logo=amazonaws" alt="AWS Serverless">
  <img src="https://img.shields.io/badge/Python-3.12-blue?style=for-the-badge&logo=python" alt="Python 3.12">
  <img src="https://img.shields.io/badge/Terraform-1.16-purple?style=for-the-badge&logo=terraform" alt="Terraform">
  <img src="https://img.shields.io/badge/GitHub_Actions-CI%2FCD-black?style=for-the-badge&logo=githubactions" alt="GitHub Actions">
</p>

<p align="center">
  <b>Production-style serverless microservices platform built on AWS with event-driven architecture, reliability, observability, Infrastructure as Code and CI/CD.</b>
</p>

---

## 🚀 Overview

This project is a production-style **serverless microservices platform on AWS** designed around independent services, asynchronous event-driven communication and managed cloud services.

The platform demonstrates how multiple serverless services can communicate through APIs, EventBridge and SQS while maintaining independent data ownership, failure handling, observability and automated infrastructure management.

### Core capabilities

- Serverless microservices
- REST APIs
- Event-driven architecture
- Asynchronous communication
- Event fan-out
- Queue-based background processing
- Retry mechanisms
- Dead-letter queues
- Idempotent event processing
- DynamoDB data persistence
- CloudWatch monitoring
- Terraform Infrastructure as Code
- GitHub Actions CI/CD
- GitHub OIDC authentication with AWS

---

## 🏗️ Architecture

~~~mermaid
flowchart LR

    Client["Client"]

    API["Amazon API Gateway"]

    User["User Service<br/>AWS Lambda"]
    Workout["Workout Service<br/>AWS Lambda"]

    UsersDB[("Users<br/>DynamoDB")]
    WorkoutsDB[("Workouts<br/>DynamoDB")]

    EventBridge["Amazon EventBridge"]

    Analytics["Analytics Service<br/>AWS Lambda"]
    AnalyticsDB[("Analytics<br/>DynamoDB")]

    NotificationQueue["Notification Queue<br/>Amazon SQS"]
    Worker["Notification Worker<br/>AWS Lambda"]

    AnalyticsDLQ["Analytics DLQ<br/>Amazon SQS"]
    NotificationDLQ["Notification DLQ<br/>Amazon SQS"]

    Client --> API

    API --> User
    API --> Workout

    User --> UsersDB
    Workout --> WorkoutsDB

    Workout -->|"WorkoutCreated"| EventBridge

    EventBridge --> Analytics
    EventBridge --> NotificationQueue

    Analytics --> AnalyticsDB
    Analytics --> AnalyticsDLQ

    NotificationQueue --> Worker
    Worker --> NotificationDLQ
~~~

---

## 🔄 Event-Driven Flow

The main asynchronous workflow is:

~~~text
Workout Service
      │
      │ WorkoutCreated
      ▼
Amazon EventBridge
      │
      ├──────────────────────► Analytics Service
      │                              │
      │                              ▼
      │                       Analytics DynamoDB
      │
      └──────────────────────► SQS Notification Queue
                                     │
                                     ▼
                              Notification Worker
~~~

The Workout Service does not need to know which downstream services consume its events.

This allows additional consumers to be connected to EventBridge without changing the core Workout Service implementation.

---

## 🧩 Microservices

### 👤 User Service

The User Service manages user creation and retrieval.

**Technology**

- AWS Lambda
- Amazon API Gateway
- Amazon DynamoDB
- Python 3.12

**API routes**

~~~text
GET  /users
POST /users
GET  /users/{userId}
~~~

User data is stored in a dedicated DynamoDB table owned by the User Service.

---

### 🏋️ Workout Service

The Workout Service manages workout records and publishes workout events.

**Technology**

- AWS Lambda
- Amazon API Gateway
- Amazon DynamoDB
- Amazon EventBridge
- Python 3.12

**API routes**

~~~text
GET  /workouts
POST /workouts
GET  /workouts/{workoutId}
~~~

When a workout is created:

1. The workout is stored in DynamoDB.
2. A `WorkoutCreated` event is published to EventBridge.
3. Downstream services process the event asynchronously.

---

### 📊 Analytics Service

The Analytics Service consumes `WorkoutCreated` events asynchronously.

Responsibilities include:

- Processing workout events
- Maintaining workout statistics
- Tracking workout types
- Tracking total workout duration
- Maintaining per-user analytics
- Preventing duplicate event processing
- Handling failed event processing

Analytics data is stored in its own DynamoDB table.

The service also maintains an idempotency table containing processed EventBridge event IDs.

---

### 🔔 Notification Worker

The Notification Worker demonstrates asynchronous background processing using Amazon SQS.

~~~text
EventBridge
    ↓
SQS Notification Queue
    ↓
Notification Worker Lambda
~~~

The current implementation logs successful processing rather than integrating with an external email or SMS provider.

---

## 📦 Event Contract

The platform uses an explicit event contract for `WorkoutCreated`.

~~~json
{
  "eventType": "WorkoutCreated",
  "version": "1.0",
  "source": "fittrack.workout-service",
  "detail": {
    "workoutId": "uuid",
    "userId": "uuid",
    "workoutType": "strength",
    "durationMinutes": 45,
    "createdAt": "2026-09-17T10:00:00Z"
  }
}
~~~

Event contracts are maintained under:

~~~text
architecture/events/
~~~

Current contracts:

~~~text
architecture/events/
├── workout-created.json
└── user-created.json
~~~

---

## 🛡️ Reliability

The platform implements reliability patterns at multiple layers.

### Lambda Retry Handling

Analytics Lambda failures are automatically retried.

~~~text
Analytics Lambda
       │
       ├── Success ─────────► Analytics DynamoDB
       │
       └── Failure
              │
              ▼
           Retry #1
              │
              ▼
           Retry #2
              │
              ▼
        Analytics DLQ
~~~

The failure path was intentionally tested using an invalid `WorkoutCreated` event.

The test verified:

- Lambda failure
- Automatic retries
- Retry exhaustion
- SQS DLQ delivery
- Failure metadata

---

### EventBridge Retry Handling

EventBridge targets use retry policies for target delivery failures.

A dedicated delivery DLQ is configured for the EventBridge target.

This provides protection against temporary downstream delivery failures.

---

### SQS Redrive Policy

The Notification Queue uses a dead-letter queue after repeated message-processing failures.

~~~text
Notification Queue
       │
       ├── Successful processing
       │
       └── Repeated failure
                │
                ▼
        Notification DLQ
~~~

---

### Idempotency

The Analytics Service maintains a DynamoDB table containing processed event IDs.

Before processing an event, the service attempts to record its EventBridge event ID.

If the event ID already exists, the event is treated as a duplicate.

~~~text
Event
  │
  ▼
Check Event ID
  │
  ├── New ───────► Process Event
  │
  └── Existing ──► Return Duplicate
~~~

This protects analytics processing from duplicate event delivery.

---

## 📈 Observability

Amazon CloudWatch provides application logging and operational monitoring.

### CloudWatch Logs

CloudWatch Logs are used for:

- Lambda execution logs
- Notification Worker logs
- Event processing information
- Application failures

### CloudWatch Alarms

The platform includes alarms for:

- Analytics Lambda errors
- Notification Worker Lambda errors
- Analytics DLQ messages
- Notification DLQ messages

The alarms monitor AWS Lambda and Amazon SQS metrics.

---

## 🏗️ Infrastructure as Code

All AWS infrastructure is managed using Terraform.

~~~text
terraform/
├── environments/
│   ├── dev/
│   └── prod/
│
└── modules/
    ├── api-gateway/
    └── lambda/
~~~

Reusable Terraform modules are used for:

- Lambda functions
- Lambda IAM roles
- API Gateway
- Lambda integrations
- API Gateway permissions

Terraform manages:

- DynamoDB tables
- EventBridge resources
- SQS queues
- Dead-letter queues
- IAM policies
- CloudWatch resources
- Lambda event source mappings
- Lambda failure destinations
- API Gateway resources

---

## 🔐 IAM & Security

The platform uses IAM roles and temporary credentials instead of hard-coded AWS credentials.

### GitHub OIDC

GitHub Actions authenticates to AWS through OpenID Connect.

~~~text
GitHub Actions
      │
      ▼
GitHub OIDC
      │
      ▼
AWS IAM Role
      │
      ▼
AWS Services
~~~

No long-lived AWS access keys are stored in GitHub Actions.

### Security concepts demonstrated

- IAM roles
- IAM policies
- Lambda execution roles
- GitHub OIDC federation
- Service-specific permissions
- EventBridge permissions
- SQS queue policies
- Lambda invocation permissions

---

## 🚀 CI/CD

GitHub Actions automatically validates Terraform changes.

~~~text
Git Push
    │
    ▼
GitHub Actions
    │
    ▼
Checkout Repository
    │
    ▼
AWS OIDC Authentication
    │
    ▼
Terraform Setup
    │
    ▼
Terraform Format Check
    │
    ▼
Terraform Init
    │
    ▼
Terraform Validate
    │
    ▼
Terraform Plan
~~~

The current workflow performs **Terraform validation and planning**.

Infrastructure is intentionally **not automatically applied** by the CI workflow.

---

## ⚙️ CI/CD Configuration

Workflow:

~~~text
.github/workflows/terraform.yml
~~~

Terraform version:

~~~text
1.16.0
~~~

AWS Region:

~~~text
us-east-1
~~~

GitHub Actions uses:

~~~text
aws-actions/configure-aws-credentials
~~~

to assume an AWS IAM role through GitHub OIDC.

The CI pipeline has been successfully validated end-to-end.

---

## 🧪 Testing & Validation

The platform was tested against the deployed AWS infrastructure.

### User Service

Validated:

- API availability
- User creation
- User retrieval
- DynamoDB persistence

### Workout Service

Validated:

- API availability
- Workout creation
- Workout retrieval
- DynamoDB persistence
- EventBridge event publishing

### Analytics Service

Validated:

- Event consumption
- Analytics database updates
- Idempotency
- Invalid event handling
- Lambda retry behavior
- DLQ delivery
- Failure metadata

### Notification Worker

Validated:

- EventBridge → SQS delivery
- SQS → Lambda event source mapping
- Worker processing
- CloudWatch logging

### Infrastructure

Validated:

- Terraform formatting
- Terraform validation
- Terraform planning
- GitHub Actions execution
- GitHub OIDC authentication
- AWS credential configuration

---

## 📁 Repository Structure

~~~text
serverless-microservices-platform/
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── architecture/
│   ├── architecture.md
│   ├── diagrams/
│   └── events/
│       ├── workout-created.json
│       └── user-created.json
│
├── docs/
│
├── services/
│   ├── analytics-service/
│   │   ├── README.md
│   │   ├── requirements.txt
│   │   └── src/
│   │       └── handler.py
│   │
│   ├── notification-service/
│   │   └── src/
│   │       └── handler.py
│   │
│   ├── user-service/
│   │   ├── README.md
│   │   ├── requirements.txt
│   │   ├── src/
│   │   │   └── handler.py
│   │   └── tests/
│   │
│   ├── worker-service/
│   │
│   └── workout-service/
│       ├── README.md
│       ├── requirements.txt
│       ├── src/
│       │   └── handler.py
│       └── tests/
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   │
│   └── modules/
│       ├── api-gateway/
│       └── lambda/
│
├── tests/
│
├── .gitignore
└── README.md
~~~

---

## 🧰 Technology Stack

| Category | Technology |
|---|---|
| Cloud Provider | AWS |
| Architecture | Serverless Microservices |
| API | Amazon API Gateway |
| Compute | AWS Lambda |
| Runtime | Python 3.12 |
| Event Bus | Amazon EventBridge |
| Messaging | Amazon SQS |
| Database | Amazon DynamoDB |
| Monitoring | Amazon CloudWatch |
| Identity & Access | AWS IAM |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Authentication | GitHub OIDC |
| Version Control | Git & GitHub |

---

## 💡 Key Cloud & DevOps Concepts

This project demonstrates practical implementation of:

- Serverless architecture
- Microservices architecture
- Event-driven architecture
- API-based communication
- Asynchronous messaging
- Event fan-out
- Queue-based processing
- Retry mechanisms
- Dead-letter queues
- Idempotency
- Infrastructure as Code
- Reusable Terraform modules
- IAM roles and policies
- GitHub OIDC
- CI/CD automation
- CloudWatch monitoring
- Failure handling
- Operational observability

---

## 🗂️ Project Phases

~~~text
Phase 1  → Project Foundation
Phase 2  → User Microservice
Phase 3  → Workout Microservice
Phase 4  → Event-Driven Analytics
Phase 5  → Notification Worker & SQS
Phase 6  → Observability & Reliability
Phase 7  → GitHub Actions CI/CD + AWS OIDC
Phase 8  → Documentation & Release
~~~

---

## ✅ Project Status

| Component | Status |
|---|---|
| Project Foundation | ✅ Complete |
| User Service | ✅ Complete |
| Workout Service | ✅ Complete |
| API Gateway | ✅ Complete |
| DynamoDB | ✅ Complete |
| EventBridge | ✅ Complete |
| Event Contracts | ✅ Complete |
| Analytics Service | ✅ Complete |
| Idempotency | ✅ Complete |
| Lambda Retry Handling | ✅ Complete |
| Analytics DLQ | ✅ Complete |
| Notification SQS | ✅ Complete |
| Notification Worker | ✅ Complete |
| Notification DLQ | ✅ Complete |
| CloudWatch Logs | ✅ Complete |
| CloudWatch Alarms | ✅ Complete |
| Terraform Modules | ✅ Complete |
| GitHub Actions | ✅ Complete |
| AWS OIDC Authentication | ✅ Complete |
| Terraform Format | ✅ Passing |
| Terraform Validate | ✅ Passing |
| Terraform Plan | ✅ Passing |
| Documentation | ✅ Complete |

---

## 🔮 Future Extensions

Possible future improvements include:

- Amazon S3 integration
- AWS KMS encryption
- Amazon Cognito authentication
- API authorization
- Custom API domains
- Additional event consumers
- Automated Terraform deployments
- Deployment approvals
- Advanced CloudWatch dashboards
- AWS X-Ray distributed tracing
- External email/SMS notification providers

These extensions are intentionally outside the current project scope.

---

## 👨‍💻 Author

### Ashish Thakur

**Cloud & DevOps Engineer**

Hands-on focus:

~~~text
AWS • Terraform • Kubernetes • Docker • CI/CD • GitOps • Cloud Automation
~~~

GitHub:

**@ashyT-Cloud**

---

## ⭐ Project Summary

**AWS Production Serverless Microservices Platform**

A hands-on cloud engineering project demonstrating how independent serverless services can communicate through APIs and asynchronous events while incorporating reliability, observability and automated infrastructure validation.

Built with:

**AWS • Python • Terraform • GitHub Actions**
