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

variable "project_id" {
  description = "The GCP project ID where the custom image will be created."
  type        = string
}

variable "region" {
  description = "The GCP region to run Cloud Build and store artifacts."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to run the temporary VM for image creation."
  type        = string
  default     = "us-central1-c"
}

variable "source_image" {
  description = "The source GKE Ubuntu image to customize. # (TODO) update this once available."
  type        = string
  default     = "projects/ubuntu-os-gke-cloud/global/images/ubuntu-gke-2404-1-33-amd64-v20250812"
}

variable "target_image_name" {
  description = "The name for the output custom image."
  type        = string
  default     = "my-gke-custom-ubuntu"
}

variable "target_image_family" {
  description = "The image family for the output custom image."
  type        = string
  default     = "my-gke-custom-ubuntu-family"
}
