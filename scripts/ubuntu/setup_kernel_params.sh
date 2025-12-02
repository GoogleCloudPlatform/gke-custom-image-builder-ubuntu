#!/bin/bash
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

set -ex

# Define the parameters to add to the kernel command line
KERNEL_PARAMS="init-on-alloc=off spec_rstack_overflow=off"

echo "--- Adding custom kernel parameters: ${KERNEL_PARAMS} ---"

# This command creates a new GRUB configuration file.
# Appending the parameters to GRUB_CMDLINE_LINUX_DEFAULT is the standard
# method on Ubuntu to add persistent kernel arguments.
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"\$GRUB_CMDLINE_LINUX_DEFAULT ${KERNEL_PARAMS}\"" | sudo tee /etc/default/grub.d/92-custom-gke-params.cfg

echo "--- Running update-grub to apply changes ---"

# update-grub regenerates the bootloader configuration, including our new file.
sudo update-grub

echo "--- GRUB update complete. The new parameters will be active after a reboot. ---"
