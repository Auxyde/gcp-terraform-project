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


  metadata_startup_script = <<-EOS
      apt-get update -y
      apt-get install ftp -y
      apt-get install -y apache2
      systemctl enable apache2
      systemctl start apache2

      echo "<html><body><h1>Welcome to Web Instance 1</h1></body></html>" > /var/www/html/index.html
    EOS

  network_interface {
    network    = "custom-vpc"
    subnetwork = "private-subnet"
    network_ip = "10.0.2.10"
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

  metadata_startup_script = <<-EOS
      apt-get update -y
      apt-get install -y apache2
      apt-get install ftp -y
      systemctl enable apache2
      systemctl start apache2

      echo "<html><body><h1>Welcome to Web Instance 2</h1></body></html>" > /var/www/html/index.html
    EOS

  network_interface {
    network    = "custom-vpc"
    subnetwork = "private-subnet"
    network_ip = "10.0.2.11"
  }
}

resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-micro"
  zone         = var.zone
  tags = ["bastion"]

  allow_stopping_for_update = true

  metadata = {
    enable-oslogin = "FALSE"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  metadata_startup_script = <<-EOS
    id -u webadmin &>/dev/null || adduser --disabled-password --gecos "" webadmin
    usermod -aG sudo webadmin
    echo 'webadmin:viveLeCloud123' | chpasswd

    sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
    sudo sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

    systemctl restart ssh

  EOS

    network_interface {
      network    = "custom-vpc"
      subnetwork = "public-subnet"
      network_ip = "10.0.1.10"
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
    subnetwork = "private-subnet"
    network_ip = "10.0.2.20"
  }

  metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOS
      sudo apt-get update -y
      sudo apt-get install -y haproxy

      cat >/etc/haproxy/haproxy.cfg  <<'CFG'
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

resource "google_compute_instance" "ftp" {
  name         = "ftp"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["ftp"]

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
    network_ip = "10.0.2.30"
  }


  metadata_startup_script = <<-EOS
      apt-get update -y
      apt-get install -y vsftpd

      sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
      sed -i 's/local_enable=YES/#local_enable=YES/' /etc/vsftpd.conf
      sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
      sed -i 's/listen=NO/listen=YES/' /etc/vsftpd.conf
      sed -i 's/listen_ipv6=YES/listen_ipv6=NO/' /etc/vsftpd.conf

      systemctl enable vsftpd
      systemctl restart vsftpd
  EOS
}
