
provider "google" {
  credentials = file(var.gcp-credentials)
  project     = var.project_id
  region      = var.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}