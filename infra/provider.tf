# Setup Providers for GCP
provider "google" {
  project = var.project_id
  region  = var.region
}
# Set up a kubernetes provider. This is getting populated from the GKE endpoint.
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}