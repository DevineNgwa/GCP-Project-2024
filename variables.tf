variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "project_name" {
  description = "A name for the project, used in resource naming"
  type        = string
  default     = "gcp-terraform-435118"
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "The machine type for the instances"
  type        = string
  default     = "e2-micro"
}