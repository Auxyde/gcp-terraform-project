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

resource "google_compute_instance" "haproxy" {
  name         = "haproxy"
  machine_type = "e2-micro"
  zone         = var.zone
  tags = ["haproxy"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }
  
  network_interface {
    network    = "custom-vpc"
    subnetwork = "public-subnet"
  }

  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOS
      apt-get update -y
      apt-get install -y haproxy

      cat >/etc/haproxy/  <<'CFG'
        global
          log /dev/log local0
          maxconn 2048
          daemon

        defaults
          log     global
          mode    http
          option  httplog
          option  dontlognull

        frontend http-in
          bind *:80
          default_backend web-pool

        backend web-pool
          balance roundrobin
          option httpchk GET /
          http-check expect status 200
          server web1 ${google_compute_instance.web1.network_interface[0].network_ip}:80 check
          server web2 ${google_compute_instance.web2.network_interface[0].network_ip}:80 check
      CFG

      systemctl enable haproxy
      systemctl restart haproxy
    EOS
}