variable "projectId" {
  default = "dezc-412217"
}

variable "region" {
  description = "Region"
  default     = "southamerica-east1"
}

variable "zone" {
  description = "Zone"
  default     = "southamerica-east1-a"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "ny_taxi_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "dezc-412217-gcp-bucket"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key"
  type = string
  default = "/home/felipe/.ssh/gcp.pub"
}