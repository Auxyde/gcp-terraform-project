resource "google_compute_router" "nat_router" {
  name    = "nat-gateway"
  network = "custom-vpc"
  region  = var.region
}

resource "google_compute_address" "nat_ip" {
  name   = "nat-ip-1"
  region = var.region
}

resource "google_compute_router_nat" "nat" {
    name                        = "nat-router"
    region                      = var.region
    router                      = google_compute_router.nat_router.name
    nat_ip_allocate_option      = "MANUAL_ONLY"
    nat_ips                     = [google_compute_address.nat_ip.self_link]

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name                    = "private-subnet"
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
}