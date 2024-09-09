# Configure the Google Cloud provider
provider "google" {
  credentials = "key.json"
  project     = var.project_id
  region      = var.region
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_name}-vpc-network"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Create a firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "${var.project_name}-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create Compute Engine instances
resource "google_compute_instance" "web_instances" {
  count        = var.instance_count
  name         = "${var.project_name}-web-instance-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              echo "Hello from Instance ${count.index + 1}" > /var/www/html/index.html
              systemctl start apache2
              systemctl enable apache2
              EOF

  tags = ["web-server"]
}

# Create a health check
resource "google_compute_health_check" "http_health_check" {
  name               = "${var.project_name}-http-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  http_health_check {
    port = 80
  }
}

# Create a backend service
resource "google_compute_backend_service" "web_backend_service" {
  name          = "${var.project_name}-web-backend-service"
  health_checks = [google_compute_health_check.http_health_check.id]

  backend {
    group = google_compute_instance_group.web_instance_group.id
  }
}

# Create an instance group
resource "google_compute_instance_group" "web_instance_group" {
  name      = "${var.project_name}-web-instance-group"
  zone      = var.zone
  instances = google_compute_instance.web_instances[*].self_link

  named_port {
    name = "http"
    port = 80
  }
}

# Create a URL map
resource "google_compute_url_map" "web_url_map" {
  name            = "${var.project_name}-web-url-map"
  default_service = google_compute_backend_service.web_backend_service.id
}

# Create a target HTTP proxy
resource "google_compute_target_http_proxy" "web_target_proxy" {
  name    = "${var.project_name}-web-target-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

# Create a global forwarding rule (Load Balancer)
resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name       = "${var.project_name}-web-forwarding-rule"
  target     = google_compute_target_http_proxy.web_target_proxy.id
  port_range = "80"
}