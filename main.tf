# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# main.tf

# This Terraform configuration sets up a Cloud Build pipeline to create custom GKE Ubuntu images.
# It provisions a GCS bucket for scripts, a service account for Cloud Build,
# and the necessary IAM permissions.

# Create a GCS bucket to store build scripts and artifacts
resource "google_storage_bucket" "imagebuild_scripts" {
  project      = var.project_id
  name         = "${var.project_id}-imagebuild-scripts"
  location     = "US"
  uniform_bucket_level_access = true
  force_destroy = false
}

# Create a dedicated service account for the image building process
resource "google_service_account" "imagebuild_sa" {
  project      = var.project_id
  account_id   = "imagebuild-service-account"
  display_name = "Image Build Service Account"
}

# Grant necessary IAM roles to the service account
resource "google_project_iam_member" "imagebuild_sa_roles" {
  for_each = toset([
    "roles/cloudbuild.builds.builder",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/iap.tunnelResourceAccessor"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.imagebuild_sa.email}"
}

# --- Cloud NAT Configuration ---
# Creates a Cloud Router to be used by Cloud NAT.
resource "google_compute_router" "nat_router" {
  project = var.project_id
  name    = "gke-imagebuild-nat-router"
  network = "default"
  region  = var.region
}

# Creates the Cloud NAT gateway to allow outbound internet access for VMs without external IPs.
resource "google_compute_router_nat" "nat_config" {
  project                               = var.project_id
  name                                  = "gke-imagebuild-nat-config"
  router                                = google_compute_router.nat_router.name
  region                                = google_compute_router.nat_router.region
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option                = "AUTO_ONLY"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# Upload the customization scripts to the GCS bucket
resource "google_storage_bucket_object" "packer_template" {
  bucket = google_storage_bucket.imagebuild_scripts.name
  name   = "ubuntu_scripts/customize_ubuntu.pkr.hcl"
  source = "${path.module}/scripts/ubuntu/customize_ubuntu.pkr.hcl"
}

resource "google_storage_bucket_object" "install_packages_script" {
  bucket = google_storage_bucket.imagebuild_scripts.name
  name   = "ubuntu_scripts/install_packages.sh"
  source = "${path.module}/scripts/ubuntu/install_packages.sh"
}

resource "google_storage_bucket_object" "setup_kernel_params_script" {
  bucket = google_storage_bucket.imagebuild_scripts.name
  name   = "ubuntu_scripts/setup_kernel_params.sh"
  source = "${path.module}/scripts/ubuntu/setup_kernel_params.sh"
}


# Module to define the Cloud Build pipeline for the Ubuntu image
module "gke-ubuntu-image-pipeline" {
  # TODO(b/442893863): Change to use an official Google Cloud repo.
  source  = "github.com/lornaluo/compute-image-import//image_builder/modules/imagebuild"
  project_id = var.project_id
  pipeline_name = "gke-ubuntu-custom-image-build"
  region = var.region
  zone = var.zone
  gcs_folder = "${google_storage_bucket.imagebuild_scripts.name}/ubuntu_scripts/"
  source_image = ({
    image = var.source_image
  })
  target_image_name = var.target_image_name
  target_image_family = var.target_image_family
  service_account_id = google_service_account.imagebuild_sa.name
  
  customization_script_source = "${path.root}/scripts/ubuntu/customize_ubuntu.pkr.hcl"
  #customization_script_source = ""
}
