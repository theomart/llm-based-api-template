# Required boilerplate to indicate to Terraform that we are using Google Cloud
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Required boilerplate to communicate with Google Cloud
provider "google" {
  project = var.project_id
  region  = var.region
}

# Variables are commonly defined in a separate file (e.g. variables.tf) when project grows
variable "project_id" {
  description = "The GCP project ID"
  default     = "your-project-id"  # TO_REPLACE: Replace with your actual project ID
}

variable "region" {
  description = "The GCP region"
  default     = "us-central1"  # TO_REPLACE: Replace with your preferred region
}

variable "service_account_name" {
  description = "The name of the service account to create"
  default     = "github-actions-sa"  # TO_REPLACE (optional): Replace with your preferred service account name
}

variable "pool_id" {
  description = "The Workload Identity Pool ID"
  default     = "github"  # TO_REPLACE (optional): Replace with your preferred pool ID
}

variable "github_repo" {
  description = "The GitHub repository in the format 'owner/repo'"
  default     = "your-github-username/your-repo-name"  # TO_REPLACE: Replace with your GitHub repo
}

locals {
  # Split the GitHub repository into owner and repo name
  # e.g. "theomart/llm-api-template" -> ["theomart", "llm-api-template"]
  repo_parts = split("/", var.github_repo)
  repo_name  = length(local.repo_parts) > 1 ? local.repo_parts[1] : ""
}

# Creates a service account for the GitHub Actions workflow
resource "google_service_account" "github_actions_sa" {
  account_id   = var.service_account_name
  display_name = "Service Account for GitHub Actions in ${var.github_repo}"
  project      = var.project_id
}

# Creates a Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = var.pool_id
  description               = "${var.github_repo}"
  display_name              = "GitHub Actions Pool"
  project                   = var.project_id
}

# Create a Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = local.repo_name
  display_name                       = "${var.github_repo}"
  
  # Maps the GitHub Actions claims to the Google Cloud claims
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  attribute_condition = "assertion.repository_owner == '${local.repo_parts[0]}'"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  project = var.project_id
}

# Allow authentications from the Workload Identity Provider to impersonate the Service Account
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}

# Add IAM roles to the service account
resource "google_project_iam_member" "service_account_roles" {
  project = var.project_id
  for_each = toset([
    "roles/run.admin", # Required to deploy the application on Cloud Run
    "roles/storage.admin", # Required to push the image to the Artifact Registry
    "roles/artifactregistry.writer" # Required to push the image to the Artifact Registry
    "roles/iam.serviceAccountUser", # Required to allow the Service Account to impersonate the GitHub Actions Service Account
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

# Create an Artifact Registry repository
resource "google_artifact_registry_repository" "artifact_registry_repo" {
  provider = google
  project  = var.project_id
  location = var.region
  repository_id = local.repo_name # TO_REPLACE (optional): here the repository id is the same as the github repo name
  format = "DOCKER"
  description = "Artifact Registry repository for ${var.github_repo}"
}

# Output the Workload Identity Provider resource name
output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}

# Output the Service Account email
output "service_account_email" {
  value = google_service_account.github_actions_sa.email
}
