# 📱 Meeting Application for Mobile Users – Semester Project

## 1. Project Overview

This project is a **semester-long academic project** implementing a **meeting and event management application for mobile users**.

The application is built using a **microservices-oriented architecture** and deployed using **cloud-native DevOps practices**.

The system includes:
- A mobile frontend application
- **Multiple RESTful backend microservices**
- A fully automated CI/CD pipeline
- Deployment on Kubernetes using Helm charts

The main focus of the project is on **DevOps, containerization, and Kubernetes orchestration**.

---

## 2. High-Level Architecture

The system is composed of three main layers:

- **Frontend**
  - Mobile application for phone users
- **Backend**
  - Several RESTful microservices
  - Each service handles a specific business domain
- **Infrastructure**
  - Docker, GitLab CI/CD, Kubernetes, Helm

## 3. Application Features

The application is designed as a **mobile-first meeting management platform** and provides the following core features:

- **User authentication**
  - Secure login using OpenID Connect (OIDC)
  - Authentication handled via Auth0
  - JWT-based session management

- **Role-based access control**
  - Different user roles (e.g. Admin, Organizer, User)
  - Access to features restricted based on user roles

- **Meeting and event management**
  - Creation and management of meetings/events
  - User participation and registration
  - Calendar-based visualization of events

- **Mobile-first experience**
  - Designed primarily for phone users
  - Flutter-based responsive UI
  - Optimized for Android and iOS devices

- **Microservices-based backend**
  - Multiple independent RESTful backend services
  - Each service responsible for a specific business domain
  - Stateless services communicating via REST APIs

- **Secure communication**
  - All backend endpoints protected
  - Token validation performed by backend services
  - No direct database access from the frontend

## 4. Technology Stack

This project relies on a **modern and cloud-native technology stack**, covering application development, authentication, and deployment.

### 4.1 Frontend
- **Flutter**
- Mobile application for Android and iOS
- REST API communication with backend services
- Environment-based configuration

### 4.2 Backend
- **Java**
- **Quarkus**
- RESTful microservices architecture
- OpenID Connect (OIDC)
- JWT-based authentication
- Integration with Auth0 for identity and role management

### 4.3 Authentication & Authorization
- **OpenID Connect (OIDC)**
- **Auth0**
- Centralized identity provider
- Role-based access control enforced by backend services

### 4.4 DevOps & Infrastructure
- **Docker**
  - Containerization of all services
- **GitLab CI/CD**
  - Automated build and deployment pipelines
- **GitLab Container Registry**
  - Storage of Docker images
- **Kubernetes**
  - Container orchestration and service management
- **Helm**
  - Deployment automation and configuration management
- **YAML**
  - CI/CD pipelines, Kubernetes manifests, and Helm charts

## 6. CI/CD Pipeline

The project uses **GitLab CI/CD** to provide a **fully automated build, test, analysis, and deployment pipeline** for all components.

### Step 1 – Source Code Update
Developers push code changes to the GitLab repository.

### Step 2 – Pipeline Trigger
Each push automatically triggers the GitLab CI/CD pipeline defined in `.gitlab-ci.yml`.

### Step 3 – Unit Tests
The pipeline executes **unit tests** for backend microservices to verify:
- Business logic correctness
- Isolated component behavior

Tests are executed automatically on each commit.

### Step 4 – Integration Tests
**Integration tests** are run to validate:
- Interactions between components
- REST API behavior
- Configuration correctness

This ensures services work correctly together before deployment.

### Step 5 – Code Quality & Coverage Analysis
The pipeline integrates **SonarQube** to perform:
- Static code analysis
- Code quality checks
- **Test coverage analysis**

Quality gates are used to ensure minimum standards are met before deployment.

### Step 6 – Docker Image Build
After successful tests and analysis, Docker images are built for:
- All backend microservices
- The frontend application

Each image is tagged using the commit hash or version number.

### Step 7 – Container Registry
The built images are pushed to the **GitLab Container Registry**, ensuring centralized storage and versioning.

### Step 8 – Kubernetes Deployment
The pipeline deploys the application to Kubernetes using **Helm charts**:
- Backend microservices as Kubernetes Deployments
- Frontend as a separate Deployment

### Step 9 – Runtime Management
Kubernetes handles:
- Pod scheduling
- Health checks
- Restart of failed containers

This pipeline guarantees **code quality, reliability, and reproducible deployments**.
