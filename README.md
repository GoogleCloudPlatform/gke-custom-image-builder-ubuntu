# GKE Custom Image Builder - Ubuntu

This repository provides a template for building custom Ubuntu images for GKE using Google Cloud Build. The examples provided utilize HashiCorp Packer, a popular open-source tool well-suited for creating machine images, run within a Cloud Build pipeline. This pipeline helps you create repeatable, automated, and version-controlled custom images.

**This is not an officially supported Google product.** This project is not eligible for the Google Open Source Software Vulnerability Rewards Program. The templates and scripts in this repository are provided as a starting point. You are responsible for the security, correctness, and compatibility of any images built using this pipeline. Google does not provide support for HashiCorp Packer.

## Overview

This template sets up an automated pipeline using:

*   **Google Cloud Build:** To run the image creation process in a managed environment.
*   **Terraform:** To provision the necessary Cloud Build triggers, service accounts, and Artifact Registry repository.
*   **Example Configurations:** The examples use configuration files (`*.pkr.hcl`) designed for use with HashiCorp Packer. The Cloud Build pipeline is configured to use a Packer container image from your Artifact Registry.


## Prerequisites

*   Obtain the “GKE Custom Image Builder Toolkit” user guide from your Google Cloud Technical Account Manager.
*   An active Google Cloud project with billing enabled.
*   The following APIs enabled: Compute Engine, Cloud Build, IAM, and Cloud Storage.
*   Google Cloud SDK (`gcloud`) installed and authenticated on your local machine.
*   Terraform installed on your local machine.

## Hosting Packer in Artifact Registry (Recommended)

For enhanced security and version control, it is recommended to host the Packer builder image in your own Artifact Registry. By default, Cloud Build might use public builder images.

This template assumes you have a Packer container image available in your Artifact Registry. You can obtain the Host Packer in AR user guide from Google Cloud Technical Account Manager to build and push a Packer image.


## How to Build Custom Image

1.  **Configure Your Environment**

    *   In the root of this repository, create a `terraform.tfvars` file. This file is where you will provide your project-specific settings.
    *   Add the following content to your `terraform.tfvars` file, replacing the placeholder values with your own:

    ```terraform
    project_id          = "your-gcp-project-id"
    # Example, please change
    source_image        = "projects/ubuntu-os-gke-cloud/global/images/ubuntu-gke-2404-1-33-amd64-v20250812"

    # Note: The target_image_name must include the substring "ubuntu".
    target_image_name   = "my-gke-custom-ubuntu"
    target_image_family = "my-gke-custom-ubuntu-family"
    ```

    *   See `variables.tf` for other optional variables you can override.

2.  **Customize the Build**

    *   **`scripts/ubuntu/customize_ubuntu.pkr.hcl`:** This is the main Packer template. Modify the `provisioner` blocks to add your desired customizations.
    *   **`scripts/ubuntu/`:** Add any shell scripts referenced by your Packer template in this directory.
    *   **`main.tf`:** Add new resource blocks for your new shell scripts, so that the scripts can be uploaded to the GCS bucket by `terraform apply`.

3.  **Deploy the Pipeline**

    *   Initialize Terraform. This will download the necessary providers and set up the local module.
        ```bash
        terraform init
        ```
    *   Apply the Terraform configuration. This will provision all the GCP resources and create the Cloud Build trigger.
        ```bash
        terraform apply
        ```

4.  **Run the Build**

    *   To initiate a build, navigate to the **Cloud Build > Triggers** page in the Google Cloud Console. Find the trigger named `gke-ubuntu-custom-image-build` (or your custom `trigger_name`) and click the "Run" button to manually trigger the build.
    *   You can monitor the build progress in the Cloud Build History page.


5.  **Verify the Image**

    *   After the Triggers `Run` command completes, your new image will be available in your GCP project. You can find it in the Google Cloud Console under **Compute Engine > Images**.
    *   The image will be named according to your `target_image_name` variable, with a unique build ID appended to it (e.g., `my-gke-custom-ubuntu-xxxxxxxx`).

## Disclaimer

This repository provides templates and examples. You are responsible for any modifications and the resulting images. Google does not provide support for third-party tools like HashiCorp Packer.
