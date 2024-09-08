To deploy a Docker image to a Kubernetes cluster on Google Cloud Platform (GCP) using Docker Compose and set up a CI/CD pipeline with GitHub Actions, follow these detailed steps:

### **1. Setup Google Cloud Platform (GCP)**

#### **1.1 Create a Google Cloud Project**

1. **Go to Google Cloud Console:**
   - Open [Google Cloud Console](https://console.cloud.google.com/).

2. **Create a New Project:**
   - Click on the **project dropdown** at the top.
   - Click **New Project** and fill in the details (Project Name, Billing Account).
   - Click **Create**.

3. **Note the Project ID:**
   - You’ll need this for configuring GitHub Actions and Docker commands.

#### **1.2 Enable APIs**

1. **Enable Kubernetes Engine API:**
   - Go to **APIs & Services > Library**.
   - Search for **Kubernetes Engine API**.
   - Click **Enable**.

2. **Enable Container Registry API:**
   - Search for **Container Registry API**.
   - Click **Enable**.

#### **1.3 Create a Service Account**

1. **Navigate to IAM & Admin:**
   - Go to **IAM & Admin > Service accounts**.

2. **Create Service Account:**
   - Click **Create Service Account**.
   - Enter a **Name** (e.g., `github-actions`).
   - Click **Create**.

3. **Assign Roles:**
   - Assign roles such as:
     - **Kubernetes Engine Developer**
     - **Storage Admin**
   - Click **Continue** and **Done**.

4. **Create and Download a Key:**
   - Find your service account and click on it.
   - Go to **Keys** tab.
   - Click **Add Key** > **Create new key**.
   - Select **JSON** and click **Create**.
   - Download and securely store the JSON key file.

### **2. Create Docker Image**

#### **2.1 Dockerfile Creation**

Create a `Dockerfile` in your project directory. For your static application, a simple `Dockerfile` looks like this:

```Dockerfile
# Use the official Nginx image from the Docker Hub
FROM nginx:alpine

# Copy the static files to the Nginx web server directory
COPY index.html /usr/share/nginx/html/
COPY script.js /usr/share/nginx/html/
```

#### **2.2 Build and Tag Docker Image**

1. **Build Docker Image:**
   ```bash
   docker build -t my-static-app .
   ```

2. **Tag Docker Image:**
   Replace `YOUR_PROJECT_ID` with your actual Google Cloud Project ID.

   ```bash
   docker tag my-static-app gcr.io/YOUR_PROJECT_ID/my-static-app
   ```

### **3. Push Docker Image to Google Container Registry (GCR)**

#### **3.1 Authenticate Docker with GCP**

Run this command to configure Docker authentication:

```bash
gcloud auth configure-docker
```

#### **3.2 Push Docker Image**

```bash
docker push gcr.io/YOUR_PROJECT_ID/my-static-app
```

### **4. Deploy Docker Image to Google Kubernetes Engine (GKE)**

#### **4.1 Create Kubernetes Cluster**

1. **Go to Kubernetes Engine:**
   - Open **Kubernetes Engine** in the GCP Console.
   - Click **Create Cluster** and follow the prompts to create a cluster.

2. **Connect to the Cluster:**
   ```bash
   gcloud container clusters get-credentials YOUR_CLUSTER_NAME --zone YOUR_CLUSTER_ZONE --project YOUR_PROJECT_ID
   ```

#### **4.2 Create Kubernetes Deployment and Service Files**

**deployment.yaml**

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

**service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-static-app-service
spec:
  selector:
    app: my-static-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

#### **4.3 Apply Kubernetes Configurations**

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### **5. Set Up CI/CD Pipeline with GitHub Actions**

#### **5.1 Create GitHub Repository Secrets**

1. **Navigate to Your Repository:**
   - Go to **Settings > Secrets and variables > Actions**.

2. **Add New Secrets:**
   - **`GCP_CREDENTIALS`**: Paste the contents of your JSON key file.
   - **`GCP_PROJECT_ID`**: Your Google Cloud Project ID.

#### **5.2 Create GitHub Actions Workflow**

Create a file `.github/workflows/deploy.yml` in your GitHub repository with the following content:

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

      - name: Set up Google Cloud SDK
        uses: google-github-actions/setup-gcloud@v2
        with:
          version: 'latest'
          project_id: ${{ secrets.GCP_PROJECT_ID }}
          credentials: ${{ secrets.GCP_CREDENTIALS }}

      - name: Build Docker Image
        run: |
          docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/my-static-app .

      - name: Push Docker Image
        run: |
          gcloud auth configure-docker
          docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/my-static-app

      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f deployment.yaml
          kubectl apply -f service.yaml
```

### **6. Access Your Application via Public URL**

After deploying, it may take a few minutes for the external IP to be assigned. Check the service status to get the public URL:

```bash
kubectl get services
```

Look for the `EXTERNAL-IP` column in the output. Access your application using this IP address.

### **Summary**

- **Google Cloud Setup:** Create and configure a project, enable APIs, create a service account.
- **Docker Image:** Create a Dockerfile, build, tag, and push the Docker image to GCR.
- **Kubernetes Deployment:** Set up a GKE cluster, deploy your image using Kubernetes YAML files.
- **CI/CD Pipeline:** Configure GitHub Actions to build, push, and deploy your Docker image automatically.

Following these steps will help you deploy your static application to Kubernetes on GCP and set up a CI/CD pipeline with GitHub Actions. Let me know if you need further clarification or assistance!