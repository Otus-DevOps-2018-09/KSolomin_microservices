provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_firewall" "firewall_reddit" {
  name    = "allow-9292"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  target_tags = ["docker-reddit"]
}

resource "google_compute_instance" "docker-reddit" {
  name         = "docker-reddit-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  count        = "${var.instances_count}"
  tags         = ["docker-reddit"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    private_key = "${file(var.private_key_path)}"
  }
} 