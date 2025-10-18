resource "google_compute_instance" "web1" {
  name         = "web-instance-1"
  machine_type = "e2-micro"
  zone         = var.zone
  tags        = ["web"]

  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = "custom-vpc"
    subnetwork = "private-subnet"
  }
}

resource "google_compute_instance" "web2" {
  name         = "web-instance-2"
  machine_type = "e2-micro"
  zone         = var.zone
  tags        = ["web"]

  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = "custom-vpc"
    subnetwork = "private-subnet"
  }
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = var.zone
  tags = ["bastion"]

  allow_stopping_for_update = true

  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = "custom-vpc"
    subnetwork = "public-subnet"
    access_config {} 
  }
}