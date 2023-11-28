
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
  node_pools = [
    {
      name = "liatrio-gke-node-pool"
      min_count = 1
      max_count = 2
      machine_type = "e2-small"
      initial_node_count = 1
      disk_size_gb = 10
    }
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  node_pools_metadata = {
    liatrio-gke-node-pool = {
      shutdown-script = "kubectl --kubeconfig=/var/lib/kubelet/kubeconfig drain --force=true --ignore-daemonsets=true --delete-local-data \"$HOSTNAME\""
    }
  }
  node_pools_labels = {
    all = {}
    pool-01 = {
      liatrio-pool-1 = true
    }
  }
}

