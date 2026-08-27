Container Security Lab — Node.js & Docker

A lightweight container-security lab built around a minimal Node.js HTTP application and a hardened Docker image.

The project focuses on container hardening, least-privilege execution, and reproducible infrastructure configuration. It is intentionally small so that the security characteristics of the container can be inspected and tested without a large application stack.

Project status: This repository currently contains the Node.js application, Docker configuration, and a local Terraform-based registry mock. Kubernetes manifests and a full CI/CD security pipeline are not currently implemented.

Overview

The application is a minimal HTTP server written using Node.js's built-in http module.

The container is designed with basic security principles including:

Minimal application dependencies
Alpine-based container images
Non-root container execution
Reduced runtime packages
Removal of Alpine package-cache artifacts
Separation between build and runtime stages in the Dockerfile
Terraform configuration for a local container-registry simulation

The project is suitable as a starting point for experimenting with container-security tooling such as Trivy, Grype, Hadolint, Syft, Cosign, and Kubernetes admission policies.

Architecture

The current implementation is intentionally simple:

                    Developer
                       |
                       v
                +--------------+
                | Node.js App  |
                +--------------+
                       |
                       v
                +--------------+
                |   Docker     |
                |    Image     |
                +--------------+
                       |
                       v
                +--------------+
                | Local Docker |
                |   Registry   |
                |  localhost   |
                |    :5000     |
                +--------------+

                Terraform
                    |
                    v
          Local Registry Mock
          (null_resource)


The Terraform configuration does not provision Amazon ECR or a Kubernetes cluster. It currently creates a null_resource that prints a message and exposes localhost:5000/k8s-sec-app as a simulated registry URL. {"fallbackMarkdown":"(GitHub
)","reference":{"matched_text":"","prefix":null,"start_idx":2671,"end_idx":2688,"safe_urls":["https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/terraform/main.tf"],"refs":[],"alt":"(GitHub
)","prompt_text":null,"type":"grouped_webpages","items":[{"title":"","url":"https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/terraform/main.tf","attribution":"GitHub","pub_date":null,"snippet":null,"attribution_segments":null,"supporting_websites":[],"refs":[{"turn_index":0,"ref_type":"view","ref_index":3}],"hue":null,"attributions":null}],"status":"done","style":null,"fallback_items":null,"error":null},"showLoginRequiredCard":false}

Application

The application is a zero-dependency Node.js HTTP server.

It uses Node.js's native http module rather than an external web framework. The server listens on port 3000 by default and returns a small JSON response. {"fallbackMarkdown":"(GitHub
)","reference":{"matched_text":"","prefix":null,"start_idx":2928,"end_idx":2945,"safe_urls":["https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/app/server.js"],"refs":[],"alt":"(GitHub
)","prompt_text":null,"type":"grouped_webpages","items":[{"title":"","url":"https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/app/server.js","attribution":"GitHub","pub_date":null,"snippet":null,"attribution_segments":null,"supporting_websites":[],"refs":[{"turn_index":0,"ref_type":"view","ref_index":2}],"hue":null,"attributions":null}],"status":"done","style":null,"fallback_items":null,"error":null},"showLoginRequiredCard":false}

Example response:

{
  "status": "success",
  "message": "Secure Kubernetes Application is Live!",
  "timestamp": "2026-08-27T00:00:00.000Z"
}


The port can be changed using the PORT environment variable.

Docker Security

The Dockerfile attempts to separate the build and runtime stages:

node:20-alpine
      |
      | builder stage
      v
application
      |
      v
alpine:3.20
      |
      | minimal runtime
      v
non-root Node.js process


The runtime image:

Uses Alpine Linux
Installs Node.js only in the runtime image
Removes the Alpine package cache
Creates a dedicated appuser
Runs the application as appuser instead of root
Exposes port 3000

The non-root configuration is explicitly implemented with:

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser


{"fallbackMarkdown":"(GitHub
)","reference":{"matched_text":"","prefix":null,"start_idx":3808,"end_idx":3825,"safe_urls":["https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/app/Dockerfile"],"refs":[],"alt":"(GitHub
)","prompt_text":null,"type":"grouped_webpages","items":[{"title":"","url":"https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/app/Dockerfile","attribution":"GitHub","pub_date":null,"snippet":null,"attribution_segments":null,"supporting_websites":[],"refs":[{"turn_index":0,"ref_type":"view","ref_index":1}],"hue":null,"attributions":null}],"status":"done","style":null,"fallback_items":null,"error":null},"showLoginRequiredCard":false}

Important implementation note

The Dockerfile currently defines a builder stage but does not actually install dependencies or copy artifacts from that stage into the runtime image.

Therefore, this repository should not currently be described as a fully implemented multi-stage production build.

The builder stage is currently:

FROM node:20-alpine AS builder
WORKDIR /app
COPY app/package*.json ./


while the runtime stage independently installs Node.js and copies server.js. {"fallbackMarkdown":"(GitHub
)","reference":{"matched_text":"","prefix":null,"start_idx":4335,"end_idx":4352,"safe_urls":["https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/app/Dockerfile"],"refs":[],"alt":"(GitHub
)","prompt_text":null,"type":"grouped_webpages","items":[{"title":"","url":"https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/app/Dockerfile","attribution":"GitHub","pub_date":null,"snippet":null,"attribution_segments":null,"supporting_websites":[],"refs":[{"turn_index":0,"ref_type":"view","ref_index":1}],"hue":null,"attributions":null}],"status":"done","style":null,"fallback_items":null,"error":null},"showLoginRequiredCard":false}

This is an area planned for improvement.

Terraform

Terraform is included under:

terraform/
└── main.tf


The current Terraform configuration is deliberately local and does not create AWS resources.

It uses:

resource "null_resource" "ecr_repository"


with a local-exec command that prints:

Local ECR Mock Initialized for k8s-sec-app


The Terraform output exposes:

localhost:5000/k8s-sec-app


as the simulated container-registry location. {"fallbackMarkdown":"(GitHub
)","reference":{"matched_text":"","prefix":null,"start_idx":4854,"end_idx":4871,"safe_urls":["https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/terraform/main.tf"],"refs":[],"alt":"(GitHub
)","prompt_text":null,"type":"grouped_webpages","items":[{"title":"","url":"https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/terraform/main.tf","attribution":"GitHub","pub_date":null,"snippet":null,"attribution_segments":null,"supporting_websites":[],"refs":[{"turn_index":0,"ref_type":"view","ref_index":3}],"hue":null,"attributions":null}],"status":"done","style":null,"fallback_items":null,"error":null},"showLoginRequiredCard":false}

Why a local mock?

The current implementation keeps the project independent of an AWS account while the container-security concepts are being developed.

A future version can replace this mock with a real container registry such as Amazon ECR.

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
app/package.json	Application metadata
app/Dockerfile	Container build and hardening configuration
terraform/main.tf	Local container-registry simulation
public.key	Public key material reserved for future signing/verification work
.github/workflows/deploy.yml	Reserved location for CI/CD automation
Running the Application Locally
1. Run directly with Node.js

From the app directory:

node server.js


The application listens on:

http://localhost:3000


Test it with:

curl http://localhost:3000

Building the Container

From the repository root:

docker build -f app/Dockerfile -t k8s-sec-app .


Run the container:

docker run --rm -p 3000:3000 k8s-sec-app


Then test:

curl http://localhost:3000

Verifying Non-Root Execution

The image is configured to run as appuser.

You can verify the effective user with:

docker run --rm k8s-sec-app id


The container should not run the application as UID 0 (root).

Terraform

Initialize Terraform:

cd terraform
terraform init


Review the planned changes:

terraform plan


Apply the local configuration:

terraform apply


The Terraform output should provide the simulated registry address:

localhost:5000/k8s-sec-app


Remove the local Terraform resources with:

terraform destroy

Current Security Controls

The current project implements the following security concepts:

Container-level controls
Non-root user
Dedicated application group
Minimal Node.js application
Alpine-based runtime
Removal of package-cache artifacts
Separation of build/runtime stages in the Dockerfile structure
Infrastructure
Terraform-managed configuration
Local registry simulation
No hard-coded AWS credentials
No requirement for an AWS account in the current implementation
Security Tools Planned

The repository is intended to evolve into a broader container-security pipeline.

Potential security stages include:

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


Potential tooling:

Security area	Candidate tool
Secret scanning	Gitleaks / TruffleHog
SAST	Semgrep
Dockerfile scanning	Hadolint
Image vulnerability scanning	Trivy / Grype
SBOM	Syft
Image signing	Cosign
Kubernetes policy	Kyverno / OPA Gatekeeper
IaC scanning	Checkov
CI/CD	GitHub Actions

These tools are planned extensions rather than claims about the current implementation.

Current Limitations

This repository is currently a container-security foundation rather than a complete Kubernetes security platform.

The following components are not currently implemented:

Kubernetes Deployment
Kubernetes Service
Kubernetes Namespace
Kubernetes RBAC
Kubernetes securityContext
Kubernetes NetworkPolicy
Kubernetes Pod Security Admission configuration
Kubernetes admission controller
Amazon ECR
AWS infrastructure provisioning
Container vulnerability scanning workflow
SBOM generation
Image signing workflow
Image-signature enforcement
Complete GitHub Actions CI/CD pipeline
Automated Kubernetes deployment

These are intentionally documented as future work so that the repository description accurately reflects the implementation.

Security Improvements Planned

The next development stages are:

Phase 1 — Container hardening
Complete the multi-stage Docker build
Pin runtime dependencies
Run as non-root
Drop unnecessary Linux capabilities
Add a read-only root filesystem where possible
Add container health checks
Scan the Dockerfile with Hadolint
Phase 2 — Container security pipeline

Add GitHub Actions stages for:

Secret Scan
     ↓
SAST
     ↓
Docker Build
     ↓
Trivy
     ↓
SBOM
     ↓
Cosign

Phase 3 — Kubernetes security

Add:

Deployment
Service
Namespace
ServiceAccount
RBAC
SecurityContext
Resource requests/limits
Liveness/readiness probes
NetworkPolicy
Phase 4 — Supply-chain security

Implement:

Build
  ↓
Scan
  ↓
Generate SBOM
  ↓
Sign Image
  ↓
Push Image
  ↓
Verify Signature
  ↓
Deploy

Phase 5 — Admission control

Use Kyverno or OPA Gatekeeper to enforce policies such as:

No latest image tags
Images must come from approved registries
Containers must run as non-root
Privileged containers prohibited
Privilege escalation prohibited
Linux capabilities dropped
Resource limits required
Signed images required
Project Goal

The long-term goal of this project is to demonstrate how a container can move through a secure software supply chain:

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
Trusted Registry
    |
    v
Kubernetes
    |
    v
Admission Security
    |
    v
Runtime Security


The current repository represents the initial container-hardening stage of that architecture.

License

This project is licensed under the MIT License.
:::{"fallbackMarkdown":"","reference":{"matched_text":" ","prefix":null,"start_idx":10958,"end_idx":10958,"safe_urls":[],"refs":[],"alt":"","prompt_text":null,"type":"sources_footnote","sources":[{"title":"","url":"https://raw.githubusercontent.com/lokeshVJ2002/k8s-container-security-pipeline/main/terraform/main.tf","attribution":"GitHub"}],"has_images":false},"showLoginRequiredCard":false}
