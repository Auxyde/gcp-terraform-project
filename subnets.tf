resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  depends_on = [ google_compute_network.vpc_network ]
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  network      = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.2.0/24"
    region        = var.region
    private_ip_google_access = true
    depends_on = [google_compute_network.vpc_network]
}

resource "google_compute_network" "vpc_network" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}