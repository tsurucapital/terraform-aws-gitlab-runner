output "runner_agent_sg_id" {
  description = "ID of the security group attached to the GitLab runner agent."
  value       = aws_security_group.runner.id
}

output "docker_machine_sg_id" {
  description = "ID of the security group attached to the docker machine runners."
  value       = aws_security_group.docker_machine.id
}

################################################################################
### Outputs received from config module.
################################################################################

output "config" {
  value     = local.runner_config
  sensitive = true
}
