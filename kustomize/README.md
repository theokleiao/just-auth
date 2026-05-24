# JustAuth Kustomize Demo

Running the Just Auth application in three environments: dev, staging, and production, on a local Minikube cluster using Kustomize for environment-specific configuration.

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/binaries/) installed
- [GitHub Container Registry](https://docs.github.com/en/packages/learn-github-packages/about-github-packages)
- An image of the Just Auth application in GHCR (Have you run `bash workflow.sh` to build and push images to GHCR?)

## Directory Structure

- `base/`: Base configuration for the application.
- `overlays/dev`: Development-specific configuration.
- `overlays/staging`: Staging-specific configuration.
- `overlays/production`: Production-specific configuration.

## Instructions

1. Clone the repository
2. Navigate to the kustomize directory
3. Run kustomize build to deploy for the specific environment

## Demo

```bash
# ensure minikube is running
minikube status

# navigate to the kustomize directory
cd kustomize

# --- for dev environment ---
# Create the namespace
kubectl create ns just-auth-dev

# Build and deploy the dev overlay
kubectl apply -k overlays/dev

# Check the status
kubectl get all -n just-auth-dev

# forward frontend service to localhost
kubectl port-forward -n just-auth-dev svc/frontend 8888:8888
# then open http://localhost:8888

# Clean up
kubectl delete all --all -n just-auth-dev

# --- for staging environment ---
# Create the namespace
kubectl create ns just-auth-staging

# Build and deploy the staging overlay
kubectl apply -k overlays/staging

# Check the status
kubectl get all -n just-auth-staging

# Clean up
kubectl delete all --all -n just-auth-staging

# --- for production environment ---
# Create the namespace
kubectl create ns just-auth-prod

# Build and deploy the production overlay
kubectl apply -k overlays/production

# Check the status
kubectl get all -n just-auth-prod

# Clean up
kubectl delete all --all -n just-auth-prod
```

## Notes

- In production, do not hardcode the GHCR token in secrets, use `kubectl create secret --dry-run` or a secret management tool. The placeholders are meant to be replaced with actual values.
