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

resource "google_compute_firewall" "allow_ftp_web" {
  name    = "allow-ftp-to-web"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["21"]
  }

  source_tags = ["web"]
  target_tags   = ["ftp"]
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

resource "google_compute_firewall" "haproxy_to_web_http" {
  name        = "allow-haproxy-to-web-http"
  network     = google_compute_network.vpc_network.name
  source_tags = ["haproxy"]
  target_tags = ["web"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
