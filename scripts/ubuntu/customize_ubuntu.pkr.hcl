// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

# customize_ubuntu.pkr.hcl

# This Packer template defines the build process for the custom GKE Ubuntu image.

packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.25"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

# These variables are passed in automatically by the Terraform module.
variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}

variable "source_image" {
  type = string
}

variable "target_image_name" {
  type = string
}

source "googlecompute" "gke_ubuntu" {
  project_id     = var.project_id
  zone           = var.zone
  source_image   = var.source_image
  ssh_username   = "packer"
  image_name     = var.target_image_name
  disk_size      = 20
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
  use_iap         = true
  use_internal_ip = true
  omit_external_ip = true
  network         = "default"
  ssh_timeout     = "15m"
  metadata = {
    "enable-oslogin" = "FALSE"
  }
}

build {
  sources = ["source.googlecompute.gke_ubuntu"]

  # Step 1: Upload and execute the package installation script.
  provisioner "shell" {
    script          = "install_packages.sh"
    execute_command = "sudo /bin/bash {{.Path}}"
  }

  # Step 2: Upload and execute the kernel parameter setup script.
  provisioner "shell" {
    script          = "setup_kernel_params.sh"
    execute_command = "sudo /bin/bash {{.Path}}"
  }

  # optional: Reboot the instance to apply kernel changes.
  provisioner "shell" {
    inline = ["sudo reboot"]
  }

  # optional : Wait for the instance to come back up after the reboot.
  provisioner "shell" {
    pause_before = "30s"
    inline       = ["echo 'Instance rebooted successfully.'"]
  }
}
