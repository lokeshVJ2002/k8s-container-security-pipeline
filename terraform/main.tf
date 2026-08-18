terraform {
  required_version = ">= 1.0.0"
}

# Simulated local DevSecOps infrastructure output
resource "null_resource" "ecr_repository" {
  provisioner "local-exec" {
    command = "echo 'Local ECR Mock Initialized for k8s-sec-app'"
  }
}

output "ecr_repository_url" {
  value       = "localhost:5000/k8s-sec-app"
  description = "Target local container registry URL"
}
