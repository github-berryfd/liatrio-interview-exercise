resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service                    = "container.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = false
}

resource "google_compute_network" "liatrio-vpc" {
  name                            = var.network
  routing_mode                    = "REGIONAL" #OR GLOBAL
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  depends_on                      = [google_project_service.compute, google_project_service.container]
}