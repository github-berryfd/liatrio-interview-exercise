# Required by GKE
data "google_client_config" "provider" {}

resource "google_storage_bucket" "default" {
  name = "liatrio-tf-state"
  location      = "US"
  force_destroy = false
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform_state_bucket.id
  }
  depends_on = [
    google_project_iam_member.default
  ]
}


# This module is designed to set up the GKE Engine *after* the infrastructure has been set up.
# We could of used another module to build the project with the roles, but I felt that was out of scope for this. 
# See: https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master 

module "gke" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git?ref=b6f35606ab373d5f572ff873569aeee5e5bf7f32"
  # version = "29.0.0"

  depends_on = [google_compute_subnetwork.private, google_compute_network.liatrio-vpc]

  # This should be used as a variable instead of hard-coded
  name = var.cluster_name

  # Project_ID Is the Google Cloud Project Id
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
  node_pools = [
    {
      name               = var.node_pool_name
      min_count          = 1
      max_count          = 3
      machine_type       = "e2-small"
      initial_node_count = 1
      disk_size_gb       = 10
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  # Clear any data that may accidentally be persisted
  node_pools_metadata = {
    liatrio-gke-node-pool = {
      shutdown-script = "kubectl --kubeconfig=/var/lib/kubelet/kubeconfig drain --force=true --ignore-daemonsets=true --delete-local-data \"$HOSTNAME\""
    }
  }
  node_pools_labels = {
    all = {}
    liatrio-gke-node-pool = {
      liatrio-pool-1 = true
    }
  }
}

