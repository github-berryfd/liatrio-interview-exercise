# Liatrio Interview Exercise

This repository is an interview exercise for Liatrio. The service is designed to test configurations, provision and set up infrastructure, build and publish the service image, and update any services to the new version.

# Table of Contents

1. [Introduction](#liatrio-interview-exercise)
2. [Resources Used](#resources-used)
3. [Project Structure](#project-structure)
4. [Setup](#setup)
   - [Required Secrets](#required-secrets)
   - [Additional Variables](#configuration)
5. [Google Cloud Provider](#google-cloud-provider)
   - [Creating GCP Project](#create-a-gcp-project)
   - [Acquiring Secrets](#acquire-secrets)
6. [Docker Hub](#docker-hub)
7. [GitHub](#github)
   - [Setting Up Repository Environment](#setting-up-repository-environment)
8. [Running the CI/CD Pipeline](#running-the-cicd-pipeline)
   - [Pipeline Explained](#pipeline-explained)
   - [Startup Process](#startup-process)
   - [Cleanup Process](#cleanup-process)
9. [Resources](#resources)

## Resources Used
1. Golang (Service Language)
2. Terrafrom (IaC)
3. Google Cloud Provider (Cloud Hosting Service)
4. Checkov (Static Code Anaylsis for Terraform)
5. Docker & Docker Hub (Artifcatory for Service Image) 
6. Github Workflows (CI/CD)
7. Kubernetes (Container Orchestration)


# Project Structure
The project is split based on functionality. IaC is typically in a separate repository, but for simplicity, it's bundled together here. The Go app structure follows [golang-standards/project-layout](https://github.com/golang-standards/project-layout).

- `.github/workflows`: Defines the CI/CD Pipeline.
    - `build-deploy.yml`: The CI/CD workflow entry point.
    - `docker-publish.yml`: Tests the application, builds the image, and deploys it to Docker Hub.
    - `gke-deploy.yml`: Deploys Kubernetes manifest files to GKE.
    - `teardown.yml`: Cleans up the infrastructure (triggered manually).
    - `terraform.yml`: Analyzes configuration and provisions infrastructure in GCP; sets up GKE.
- `cmd/`: Contains the application's entry point.
- `deployment/docker`: The Dockerfile for building the Go image.
- `deployment/kube`: Kubernetes deployment and service manifest files.
- `infra/`: Terraform infrastructure provisioning files.
- `internal/`: Private application and library code. Enforced by Go Compiler.



# Setup

## Required Secrets
If attempting to set this repository up in your own github repository, whether by fork or not, secrets will be needed in order for the pipeline to successfully execute.
- `GKE_PROJECT_ID`: Your Google Cloud Project ID.
- `SERVICE_ACCOUNT`: Service account email for Google Kubernetes Engine authentication.
- `GCP_SA_KEY`: JSON Service account file (minified to a single line for GitHub secrets).
- `DOCKER_USERNAME`: Docker account username.
- `DOCKER_AUTH_TOKEN`: Authentication token for Docker.

## Configuration
Additional variables in `build-deploy.yml`:

- `cluster_name`: Name of the Google Kubernetes Cluster.
- `node_pool`: Name of the node pool for GKE.
- `region`: Hosting project region, typically `us-central1`.
- `network`: VPC Network name.
- `subnetwork`: Subnetwork name within the VPC.
- `ip_range_pods`: IP Range for the pods.
- `ip_range_services`: IP Range for the services.
- `image_tag`: Full name of the image for the artifactory.
- `kube_context`: Directory of Kubernetes manifest files.
- `dockerfile_path`: Path to the Dockerfile.



## Google Cloud Provider

While Terraform can be used with any cloud provider, this repository is using GCP specific modules in order to set up and reserve infrastructure. 

1. [Create a GCP Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

### Acquire Secrets

Follow these steps in the GCP Console to acquire necessary secrets:

1. Select your project
2. Navigate to IAM & Admin
3. Select Service Accounts on he left-hand navigation pane.
4. Copy the Service Account Email (SERVICE_ACCOUNT)
5. Under 'Manage Keys', create a key (JSON recommended) and download it (`GCP_SA_KEY`).

*Note: Preferably, use Workload Identity Federation (OAuth) over service account credential files.

## Docker Hub

After the Service Image has been built, we will nee to publish the image. Normally an internal artifactory would be used, but to prevent permission issues, we will use Dockers public artifactory. 

1. [Create a Docker Account](https://docs.docker.com/docker-id/)
2. In Account Settings -> Security, create a new access token named 'Liatrio Github Workflow'.
3. Copy the generated access token (`DOCKER_AUTH_TOKEN`).
4. Copy your Docker username (`DOCKER_USERNAME`).

## Github

In order to use the workflow pipeline located within the repository (.github/workflows) a Github Repository Environment must be set up. This environment will contain the secrets necessary for the application to run, and any protection rules to prevent misuse.

1. [Create a Github Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment)


# Running the CI/CD Pipeline
The CI/CD pipeline in this configuration automatically activates upon any code merge into the `main` branch.

## Pipeline Explained
The pipeline consists of several stages:

### Provision Infrastructure
1. Authenticates with Google Cloud Provider.
2. Installs Google Cloud SDK.
3. Installs Python.
4. Conducts Static Code Analysis using Checkov.
5. Installs Terraform.
6. Validates Terraform file format.
7. Initializes Terraform.
8. Creates a Terraform Plan.
9. Applies the Terraform configuration to Google Cloud Platform (GCP).


### Create Container Image
1. Installs Go.
2. Runs tests.
3. Installs Docker Buildx.
4. Logs into Docker.
5. Builds the Docker image.
6. Publishes the Docker image to Docker Hub.

### Deploy to Cloud
1. Authenticates with Google Cloud Provider.
2. Authenticates with Google Kubernetes Engine (GKE).
3. Applies Kubernetes manifest files.
4. Triggers a Deployment Update.
5. Performs rolling updates to existing pods.

## What's Running
After the pipeline is finished you will be left with a functioning Kubernetes Cluster running on Google Cloud Provider.
The infrastructure is set up as such:
- A VPC network called `liatrio-vpc-01`
- A Subnetwork with two IP Ranges called `liatrio-subnet-01`
    - An IP Range for pods called `liatrio-subnet-01-gke-01-pods`
    - An IP Range for services called `liatrio-subnet-01-gke-01-services`
- A Node Pool attached to the VPC called `liatrio-gke-node-pool`
    - type: e2-small
    - instances: 1 min, 3 max
- A Kubernetes Engine Cluster called `liatrio-gke-cluster`
- Load Balanced Kubernetes Service
- 2 Kubernetes Pods 
    - Maximum CPU: 0.5 Cores
    - Maximum Memory: 20Mi
    - A stateless Go webserver image: `berryfd/liatrio-webservice:latest`




## Startup Process
To trigger the pipeline, you can simply push a new commit to the `main` branch. This can be done with the following command, assuming there are no branch protection rules in place:

```bash
git push origin main
```

This command will initiate the automated processes defined in the CI/CD pipeline.

## Testing
Once the repository pipeline has finished, we should be able to test our endpoint. Because we don't have any sort of static IP or Domain name resolution we need to find the Endpoint IP to access our service from the kubernetes engine. 

1. Open Google Cloud Console
2. Select your Project
3. Navigate to the Kubernetes Engine Dashboard
4. Select `Services & Ingress`.
5. The publically accessible endpoint will be under `Endpoints` for `liatrio-exercise-service`
6. Replace `<endpoint>` with the IP found in step 5 and run the command.

```bash
curl http://<endpoint>/health
```

## Cleanup Process
Within the `.github/workflows` directory there is a teardown.yml file. To prevent from unintentionally running this workflow, it has been defined to only trigger manually.

1. Navigate to the Repository
2. Select `Actions`
3. Select `Tearing Down Infrastructure`
4. Select `Run workflow`
5. Fill in the necessary parameters. These can be found from the build-deploy workflow found within the repository.

* This teardown process should only be initiated from within the GitHub Actions workflow.


## Resources
- `Golang`: https://go.dev/
- `Terraform`: https://www.terraform.io/
- `Kubernetes`: https://kubernetes.io/
- `Google Cloud Provider (GCP)`: https://cloud.google.com/?hl=en
- `Google Cloud SDK`: https://cloud.google.com/sdk/docs/install-sdk
- `Golang Project Structure Standard`: https://github.com/golang-standards/project-layout
- `Golang Http Router`: https://github.com/julienschmidt/httprouter
- `Terrafrom GKE Module`:https://github.com/terraform-google-modules/terraform-google-kubernetes-engine
- `Checkov`: https://github.com/bridgecrewio/checkov#getting-started
- `Github Reusable Workflow`: https://docs.github.com/en/enterprise-cloud@latest/actions/using-workflows/reusing-workflows#overview
- `Github Environments`: https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets

