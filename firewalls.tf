resource "google_compute_firewall" "bastion_ssh" {
  name    = "allow-bastion-ssh"
  network = "custom-vpc"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.admin_cidr]
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "ssh_from_bastion" {
  name          = "allow-ssh-from-bastion-to-private"
  network       = google_compute_network.vpc_network.name
  source_tags   = ["bastion"]
  target_tags   = ["web"]
  allow { 
    protocol = "tcp"
    ports = ["22"] 
  }
}

resource "google_compute_firewall" "bastion_to_haproxy_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_tags = ["bastion"]
  target_tags = ["haproxy"]
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}