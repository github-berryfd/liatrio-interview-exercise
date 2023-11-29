# Required by GKE
data "google_client_config" "provider" {}


# This module is designed to set up the GKE Engine *after* the infrastructure has been set up.
# We could of used another module to build the project with the roles, but I felt that was out of scope for this. 
# See: https://github.com/terraform-google-modules/terraform-google-project-factory/tree/master 

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "29.0.0"


  # This should be used as a variable instead of hard-coded
  name = "liatrio-gke-cluster"

  # Project_ID Is the Google Cloud Project Id
  project_id = var.project_id
  region     = var.region

  network    = google_compute_network.liatrio-vpc.id
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
      # This should probably be a variable too.
      name               = "liatrio-gke-node-pool"
      min_count          = 1
      max_count          = 2
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

