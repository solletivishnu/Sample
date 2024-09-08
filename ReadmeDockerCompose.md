To integrate Docker Compose into the process of deploying your static application to Google Kubernetes Engine (GKE) and setting up a CI/CD pipeline, you’ll follow these steps:

### **1. Docker Compose Setup**

Docker Compose is typically used for managing multi-container Docker applications. However, it can still be useful for local development and testing before deploying to Kubernetes. For your static app with just `index.html` and `script.js`, you would use Docker Compose to manage the local environment.

#### **1.1 Create a `docker-compose.yml` File**

Create a `docker-compose.yml` file in your project directory with the following content:

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - .:/usr/share/nginx/html
```

This file defines:
- A single service named `web` that uses the Nginx image.
- Maps port 80 in the container to port 8080 on your host machine.
- Mounts the current directory (`.`) to `/usr/share/nginx/html` in the container so that your static files are served by Nginx.

#### **1.2 Start Your Application Locally**

Run the following command to start your application using Docker Compose:

```bash
docker-compose up
```

You can access your application at `http://localhost:8080`.

### **2. Deploying to GKE**

Docker Compose isn’t directly used with Kubernetes; instead, you use Kubernetes manifests (`deployment.yaml` and `service.yaml`). However, you can use Docker Compose for local development and then deploy to Kubernetes for production.

### **3. Adapt GitHub Actions Workflow for Docker Compose**

You can use Docker Compose in your GitHub Actions workflow for building and testing the application. Here’s how to adapt the workflow to include Docker Compose:

#### **3.1 Update `.github/workflows/deploy.yml`**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Set up Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v2
        with:
          version: 'latest'
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          credentials: ${{ secrets.GCP_CREDENTIALS }}

      - name: Build Docker Compose
        run: |
          docker-compose build

      - name: Push Docker Images
        run: |
          gcloud auth configure-docker
          docker-compose push

      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f deployment.yaml
          kubectl apply -f service.yaml
```

In this workflow:
- **Set up Docker Buildx:** This step prepares the environment for building Docker images.
- **Build Docker Compose:** Builds Docker images using Docker Compose.
- **Push Docker Images:** Pushes Docker images to Google Container Registry.
- **Deploy to Kubernetes:** Applies the Kubernetes configurations to deploy your application.

### **4. Kubernetes Deployment Using Docker Compose Images**

When deploying to GKE, your Docker images should be pushed to Google Container Registry (GCR). Your Kubernetes manifests should refer to these images.

**Example Deployment YAML (adapted for Docker Compose images):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-static-app-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-static-app
  template:
    metadata:
      labels:
        app: my-static-app
    spec:
      containers:
      - name: my-static-app
        image: gcr.io/YOUR_PROJECT_ID/my-static-app
        ports:
        - containerPort: 80
```

### **Summary**

- **Docker Compose for Local Development:** Use Docker Compose to manage your local development environment.
- **Build and Push Images:** Use Docker Compose commands to build and push images in the CI/CD pipeline.
- **Deploy to Kubernetes:** Use Kubernetes manifests to deploy your images from GCR to GKE.

By following these steps, you can use Docker Compose for local development and Docker/Kubernetes for production deployment with a CI/CD pipeline.