#!/bin/bash
set -e

# Load environment variables from .env if present
set -a
[ -f .env ] && source .env
set +a

# Configuration
REGISTRY="ghcr.io"
OWNER="${GITHUB_REPOSITORY_OWNER:-$(echo ${GITHUB_REPOSITORY} | cut -d'/' -f1)}"
if [ -z "$OWNER" ]; then
    echo "Error: OWNER not set. Please set GITHUB_REPOSITORY_OWNER or ensure GITHUB_REPOSITORY is set."
    exit 1
fi

# Determine environment (dev, staging, prod)
ENV="${1:-dev}"
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
    echo "Error: Environment must be 'dev', 'staging', or 'prod'"
    exit 1
fi

# Use commit SHA as additional tag if available (for traceability)
COMMIT_TAG=""
if [ -n "$GITHUB_SHA" ]; then
    COMMIT_TAG="${GITHUB_SHA}"
fi

# Primary tag = environment name
TAG="$ENV"

FRONTEND_IMAGE="${REGISTRY}/${OWNER}/just-auth-frontend:${TAG}"
BACKEND_IMAGE="${REGISTRY}/${OWNER}/just-auth-backend:${TAG}"

echo "Building and pushing to GHCR as ${OWNER} for environment: ${ENV}"
echo "Tag: ${TAG}"

# Login to GHCR (requires GHCR_TOKEN and GH_USERNAME)
if [ -n "$GHCR_TOKEN" ] && [ -n "$GH_USERNAME" ]; then
    echo "$GHCR_TOKEN" | docker login "$REGISTRY" -u "$GH_USERNAME" --password-stdin
else
    echo "Warning: GHCR_TOKEN or GH_USERNAME not set. Attempting existing docker login."
fi

# Build backend
echo "Building backend..."
docker build -t "$BACKEND_IMAGE" ./backend
if [ -n "$COMMIT_TAG" ]; then
    docker tag "$BACKEND_IMAGE" "${REGISTRY}/${OWNER}/just-auth-backend:${COMMIT_TAG}"
fi

# Build frontend
echo "Building frontend..."
docker build -t "$FRONTEND_IMAGE" ./frontend
if [ -n "$COMMIT_TAG" ]; then
    docker tag "$FRONTEND_IMAGE" "${REGISTRY}/${OWNER}/just-auth-frontend:${COMMIT_TAG}"
fi

# Push environment tag
echo "Pushing backend (${TAG})..."
docker push "$BACKEND_IMAGE"
echo "Pushing frontend (${TAG})..."
docker push "$FRONTEND_IMAGE"

# Push commit SHA tag if available
if [ -n "$COMMIT_TAG" ]; then
    echo "Pushing backend (${COMMIT_TAG})..."
    docker push "${REGISTRY}/${OWNER}/just-auth-backend:${COMMIT_TAG}"
    echo "Pushing frontend (${COMMIT_TAG})..."
    docker push "${REGISTRY}/${OWNER}/just-auth-frontend:${COMMIT_TAG}"
fi

# For prod, also tag and push as 'latest'
if [ "$ENV" = "prod" ]; then
    echo "Tagging and pushing 'latest' for production..."
    docker tag "$BACKEND_IMAGE" "${REGISTRY}/${OWNER}/just-auth-backend:latest"
    docker tag "$FRONTEND_IMAGE" "${REGISTRY}/${OWNER}/just-auth-frontend:latest"
    docker push "${REGISTRY}/${OWNER}/just-auth-backend:latest"
    docker push "${REGISTRY}/${OWNER}/just-auth-frontend:latest"
fi

echo "Done. Images pushed for environment '${ENV}':"
echo "  ${BACKEND_IMAGE}"
echo "  ${FRONTEND_IMAGE}"
if [ -n "$COMMIT_TAG" ]; then
    echo "  Also tagged with commit SHA: ${COMMIT_TAG}"
fi
if [ "$ENV" = "prod" ]; then
    echo "  Also tagged as 'latest'"
fi