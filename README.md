Container Security Lab — Node.js & Docker

A lightweight container-security lab built around a minimal Node.js HTTP application and a security-focused Docker configuration.

The project demonstrates basic container-hardening concepts such as non-root execution, minimal runtime dependencies, Alpine-based images, and infrastructure configuration with Terraform.

Current status: This repository is currently a container-security foundation. It includes a Node.js application, Docker configuration, and a Terraform-based local registry mock. Kubernetes manifests, AWS ECR integration, vulnerability scanning, image signing, and a complete CI/CD security pipeline are not currently implemented.

Overview

The application is a minimal HTTP server built using Node.js's native http module.

The project focuses on keeping the application and container simple so that container-security concepts can be inspected and tested without the complexity of a large application stack.

Currently implemented
Minimal Node.js HTTP application
Alpine-based Docker images
Dedicated non-root application user
Reduced runtime packages
Removal of Alpine package-cache artifacts
Dockerfile with separate builder and runtime stages
Terraform configuration
Local container-registry simulation
Not currently implemented
Kubernetes deployment
Amazon ECR
GitHub Actions CI/CD pipeline
Container vulnerability scanning
SBOM generation
Image signing and verification
Kubernetes admission policies
Kubernetes RBAC
Kubernetes NetworkPolicy

These features are documented as future improvements rather than current capabilities.

Architecture

The current implementation is intentionally small:

                         Developer
                            |
              +-------------+-------------+
              |                           |
              v                           v
       +--------------+            +--------------+
       |  Node.js App |            |  Terraform   |
       +--------------+            +--------------+
              |                           |
              v                           v
       +--------------+            +--------------+
       | Docker Image |            | Registry Mock|
       +--------------+            +--------------+
              |                    localhost:5000
              |                    /k8s-sec-app
              |
              v
       Local Container


The Terraform configuration does not provision Amazon ECR, Kubernetes, or AWS infrastructure.

Instead, it currently uses a Terraform null_resource with a local-exec provisioner to simulate an ECR repository and exposes:

localhost:5000/k8s-sec-app


as a mock registry URL.

This keeps the project independent of an AWS account while the container-security foundation is being developed.

Application

The application is a minimal Node.js HTTP server with no external runtime dependencies.

It uses Node.js's built-in http module and listens on port 3000 by default.

The application returns a JSON response containing:

Application status
Application message
Current timestamp

The port can be changed using the PORT environment variable.

Example response
{
  "status": "success",
  "message": "Secure Kubernetes Application is Live!",
  "timestamp": "2026-08-27T00:00:00.000Z"
}


Note: The response message still contains the phrase "Kubernetes Application", but the current repository does not deploy the application to Kubernetes. This message can be renamed in a future cleanup to avoid confusion.

Docker Configuration

The Dockerfile contains separate builder and runtime stages.

The current structure is:

node:20-alpine
      |
      | Builder stage
      |
      v
Application files
      |
      | Runtime stage
      v
alpine:3.20
      |
      v
Node.js runtime
      |
      v
Non-root application user

Current container controls

The runtime image:

Uses Alpine Linux
Installs Node.js in the runtime image
Removes Alpine package-cache artifacts
Creates a dedicated application group
Creates a dedicated application user
Runs the application as the non-root user
Exposes port 3000

The non-root configuration is:

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser


Running the application as a non-root user reduces the impact of a potential container compromise compared with running the application as root.

Dockerfile Implementation Note

Although the Dockerfile contains a builder stage, the current implementation does not fully use the builder stage.

The builder currently performs:

FROM node:20-alpine AS builder
WORKDIR /app
COPY app/package*.json ./


The runtime stage independently installs Node.js and copies server.js.

Therefore, the current Dockerfile should not be considered a fully optimized multi-stage production build.

A future version can improve this by:

Installing dependencies in the builder stage
Using npm ci
Copying only required artifacts into the runtime image
Removing unnecessary build-time content
Pinning base-image versions or digests
Adding a container health check
Reducing the runtime attack surface further
Terraform

Terraform configuration is located in:

terraform/
└── main.tf


The current Terraform configuration does not create AWS resources.

Instead, it uses:

resource "null_resource" "ecr_repository"


with a local-exec command to simulate initialization of a container registry.

The Terraform output provides:

localhost:5000/k8s-sec-app


as the simulated registry location.

Why use a mock?

The local mock allows the project to be developed without requiring:

An AWS account
AWS credentials
An Amazon ECR repository
AWS infrastructure costs

A future version can replace the mock with a real Amazon ECR repository.

Repository Structure
.
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── app/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
│
├── terraform/
│   ├── main.tf
│   └── terraform.tfstate
│
└── public.key

Main components
Component	Purpose
app/server.js	Minimal Node.js HTTP application
app/package.json	Node.js application metadata
app/Dockerfile	Container build and hardening configuration
terraform/main.tf	Local registry simulation
.github/workflows/deploy.yml	Reserved location for future CI/CD automation
public.key	Public key currently reserved for future signing/verification work
Running the Application Locally
Run with Node.js

Move into the application directory:

cd app


Start the application:

node server.js


The application listens on:

http://localhost:3000


Test it with:

curl http://localhost:3000

Build the Docker Image

From the repository root:

docker build -f app/Dockerfile -t k8s-sec-app .


Run the container:

docker run --rm -p 3000:3000 k8s-sec-app


Test the container:

curl http://localhost:3000

Verify Non-Root Execution

The container is configured to run as appuser.

You can verify the effective user with:

docker run --rm k8s-sec-app id


The application should not run as UID 0.

Terraform Usage

Move into the Terraform directory:

cd terraform


Initialize Terraform:

terraform init


Review the planned changes:

terraform plan


Apply the configuration:

terraform apply


The Terraform output provides the simulated registry address:

localhost:5000/k8s-sec-app


Destroy the local Terraform resources with:

terraform destroy

Current Security Controls

The current repository demonstrates the following security concepts.

Container security
Non-root container execution
Dedicated application user
Dedicated application group
Minimal Node.js application
Alpine-based runtime
Reduced runtime packages
Removal of package-cache artifacts
Infrastructure
Terraform-managed configuration
Local registry simulation
No AWS credentials required
No AWS account required for the current implementation
Security Tools and Pipeline — Planned

The project is intended to evolve into a complete container-security and Kubernetes supply-chain pipeline.

The planned architecture is:

Source Code
     |
     v
Secret Scanning
     |
     v
SAST
     |
     v
Dockerfile Security Scan
     |
     v
Container Build
     |
     v
Image Vulnerability Scan
     |
     v
SBOM Generation
     |
     v
Image Signing
     |
     v
Container Registry
     |
     v
Kubernetes Deployment
     |
     v
Admission Policy
     |
     v
Runtime Security

Planned tooling
Security area	Candidate tool
Secret scanning	Gitleaks / TruffleHog
SAST	Semgrep
Dockerfile scanning	Hadolint
Image vulnerability scanning	Trivy / Grype
SBOM generation	Syft
Image signing	Cosign
Kubernetes policy	Kyverno / OPA Gatekeeper
IaC scanning	Checkov
CI/CD	GitHub Actions

These tools represent the planned security architecture and are not being presented as currently implemented features.

Current Limitations

The repository is currently a container-security foundation rather than a complete Kubernetes security platform.

The following capabilities are not currently implemented:

Kubernetes Deployment
Kubernetes Service
Kubernetes Namespace
Kubernetes ServiceAccount
Kubernetes RBAC
Kubernetes securityContext
Kubernetes NetworkPolicy
Pod Security Admission configuration
Kubernetes admission controller
Amazon ECR
AWS infrastructure provisioning
Container vulnerability scanning
SBOM generation
Image signing
Image-signature verification
Image-signature enforcement
Complete GitHub Actions pipeline
Automated Kubernetes deployment
Runtime security monitoring
Repository Security Considerations
Terraform state

The current repository contains a Terraform state file:

terraform/terraform.tfstate


Terraform state files should generally not be committed to a public Git repository, because Terraform state can contain sensitive infrastructure information or secret values depending on the configuration.

For a production implementation, the state should be:

Removed from source control
Added to .gitignore
Stored in a protected remote backend
Encrypted at rest
Access-controlled

Example .gitignore entries:

.terraform/
*.tfstate
*.tfstate.*


If the state file has already been committed, removing it from the latest commit is not necessarily enough; its presence may remain in Git history.

Future Improvements
Phase 1 — Container Hardening
Complete the multi-stage Docker build
Use npm ci where appropriate
Pin base-image versions
Consider image digests for reproducibility
Add a container health check
Drop unnecessary Linux capabilities
Use a read-only root filesystem where practical
Scan the Dockerfile with Hadolint
Phase 2 — CI/CD Security

Build a GitHub Actions pipeline containing:

Secret Scan
     |
     v
SAST
     |
     v
Dockerfile Scan
     |
     v
Docker Build
     |
     v
Trivy
     |
     v
SBOM
     |
     v
Cosign

Phase 3 — Container Registry

Replace the local registry mock with Amazon ECR.

The target flow would become:

GitHub Actions
      |
      v
Build Image
      |
      v
Scan Image
      |
      v
Sign Image
      |
      v
Amazon ECR

Phase 4 — Kubernetes Security

Add:

Kubernetes Deployment
Kubernetes Service
Namespace
ServiceAccount
RBAC
SecurityContext
Resource requests and limits
Liveness probe
Readiness probe
NetworkPolicy
Phase 5 — Supply-Chain Security

Implement:

Build
  |
  v
Scan
  |
  v
Generate SBOM
  |
  v
Sign Image
  |
  v
Push Image
  |
  v
Verify Signature
  |
  v
Deploy

Phase 6 — Admission Control

Use Kyverno or OPA Gatekeeper to enforce policies such as:

Images must not use the latest tag
Images must come from approved registries
Containers must run as non-root
Privileged containers are prohibited
Privilege escalation is prohibited
Linux capabilities must be dropped
Resource limits are required
Only signed images may be deployed
Project Goal

The long-term goal is to demonstrate a secure container software-supply-chain workflow from source code to Kubernetes deployment.

The intended final architecture is:

Developer
    |
    v
Source Security
    |
    v
Secure Container Build
    |
    v
Vulnerability Scanning
    |
    v
SBOM
    |
    v
Image Signing
    |
    v
Trusted Container Registry
    |
    v
Kubernetes
    |
    v
Admission Security
    |
    v
Runtime Security


The current repository represents the initial container-hardening stage of this architecture.

Project Status

Current stage: Container Security Foundation

Implemented:

Node.js application
Docker container
Non-root execution
Alpine runtime
Basic container hardening
Terraform local registry mock

Planned:

CI/CD security pipeline
Vulnerability scanning
SBOM
Image signing
Amazon ECR
Kubernetes deployment
Kubernetes security policies
Admission control
Runtime security
License

Add a license section here only after a LICENSE file has been added to the repository.

For example, if the repository is licensed under MIT, add the MIT license file and then replace this section with:

This project is licensed under the MIT License.
