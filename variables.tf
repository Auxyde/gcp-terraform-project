variable "project_id" {
  type        = string
  description = "ID du projet GCP à gérer"
  default    = "infracloud-475109"
}

variable "region" {
  type        = string
  description = "Région GCP"
  default     = "europe-west1"
}

variable "zone" {
  type        = string
  description = "Zone GCP"
  default     = "europe-west1-b"
}

variable "admin_cidr" {
  type        = string
  description = "Your public IP/CIDR"
}