
output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "instance_names" {
  description = "The names of the created instances"
  value       = google_compute_instance.web_instances[*].name
}

output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = google_compute_global_forwarding_rule.web_forwarding_rule.ip_address
}