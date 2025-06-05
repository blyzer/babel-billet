output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.app_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app_service.name
}

output "github_actions_role_arn_dev" {
  description = "ARN of the GitHub Actions IAM role for dev"
  value       = aws_iam_role.github_actions_role_dev.arn
}

output "github_actions_role_arn_staging" {
  description = "ARN of the GitHub Actions IAM role for staging"
  value       = aws_iam_role.github_actions_role_staging.arn
}

output "github_actions_role_arn_production" {
  description = "ARN of the GitHub Actions IAM role for production"
  value       = aws_iam_role.github_actions_role_production.arn
}

output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.default.endpoint
}