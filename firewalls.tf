resource "google_compute_firewall" "bastion_ssh" {
  name    = "allow-bastion-ssh"
  network = "custom-vpc"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.205.176.2/32"] 
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}