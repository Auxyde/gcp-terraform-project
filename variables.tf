variable "project_id" {
  type        = string
  description = "ID du projet GCP à gérer"
  default    = "InfraCloud"
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