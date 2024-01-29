terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.6.0"
    }
  }
}

provider "google" {
  project = var.projectId
  region  = var.region
  zone = var.zone
}

resource "google_storage_bucket" "gcp-bucket" {
  name          = var.gcs_bucket_name
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "ny_taxi_dataset" {
  dataset_id                 = var.bq_dataset_name
  location                   = var.region
  delete_contents_on_destroy = true
}

resource "google_compute_instance" "vm_instance" {
  name         = "dezc-vm"
  machine_type = "e2-standard-4"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size = 30
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "felipe:${file(var.ssh_public_key_path)}"
  }
}