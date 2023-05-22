#terraform {
#  required_providers {
#    google = {
#      source = "hashicorp/google"
#      version = "4.53.0"
#    }
#  }
#}

terraform {
  backend "gcs" {
    bucket  = "tf-bucket-665710"
 prefix  = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.53.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region

  zone        = var.zone
}

module "instances" {

  source     = "./modules/instances"

}

module "storage" {

  source = "./modules/storage"
}

module "network" {
  source  = "terraform-google-modules/network/google"
  version = "6.0.0"
  
  project_id   = "qwiklabs-gcp-03-a2a7f304fe35"
    network_name = "tf-vpc-154914"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-east1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-east1"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        },
    ]
}

resource "google_compute_firewall" "tf-firewall"{
  name    = "tf-firewall"
 network = "projects/qwiklabs-gcp-03-a2a7f304fe35/global/networks/tf-vpc-154914"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}