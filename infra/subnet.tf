# Create the subnetwork within the VPC, there are two IP ranges, one for pods, one for services
resource "google_compute_subnetwork" "private" {
  name                     = var.subnetwork
  ip_cidr_range            = "10.0.0.0/18"
  region                   = var.region
  network                  = google_compute_network.liatrio-vpc.id
  private_ip_google_access = true
  depends_on = [ google_compute_network.liatrio-vpc ]
  secondary_ip_range {
    range_name    = var.ip_range_pods
    ip_cidr_range = "10.48.0.0/14"
  }

  secondary_ip_range {
    range_name    = var.ip_range_services
    ip_cidr_range = "10.52.0.0/20"
  }

}