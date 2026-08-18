# Stage 1: Build dependencies cleanly
FROM node:20-alpine AS builder
WORKDIR /app
COPY app/package*.json ./

# Stage 2: Hardened, minimal runtime
FROM alpine:3.20
RUN apk add --no-libc -U nodejs && rm -rf /var/cache/apk/*
WORKDIR /app

# Copy application files and built production modules only
COPY app/server.js ./

# Run as non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
