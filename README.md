# Minimal DevSecOps Node.js Application 🛡️⚡

[![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-326CE5.svg)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED.svg)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Runtime-Node.js_20-339933.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight, zero-dependency Node.js HTTP server built with security best practices, multi-stage Docker builds, and non-root execution principles for Kubernetes deployments.

---

## 📌 Features & Security Architecture

- **Multi-Stage Build:** Uses `node:20-alpine` for dependency installation and copies production assets into a minimal `alpine:3.20` base runtime.
- **Least Privilege (Non-Root):** Runs under a custom `appuser:appgroup` system account to limit container breakout risks.
- **Zero Heavy Dependencies:** Leverages native Node.js `http` modules for a tiny footprint (~40MB image size).
- **Hardened Image:** Removes `apk` cache artifacts immediately to lower Trivy/Grype CVE attack surface.

---

## 📂 Repository Structure

```text
.
├── Dockerfile          # Hardened multi-stage container configuration
└── app/
    ├── package.json    # Application metadata and startup scripts
    └── server.js       # Native Node.js JSON HTTP API server
