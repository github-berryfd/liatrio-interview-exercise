
data "google_client_config" "provider" {}

## SETUP KUBERNETES
##BUCKET FOR STATE



module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "29.0.0"


  # insert the 6 required variables here
  name = "liatrio-gke-cluster"

  #GCP Project ID
  project_id = var.project_id
  region     = var.region

  network    = var.network
  subnetwork = var.subnetwork

  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  service_account     = var.compute_engine_service_account
  deletion_protection = false

  create_service_account     = false
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
}

