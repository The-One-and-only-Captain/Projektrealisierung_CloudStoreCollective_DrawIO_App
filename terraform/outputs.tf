# ==============================================================================
# SYSTEM OUTPUTS (MANDATORY)
# Werden vom CloudStore Backend zur Verwaltung benötigt.
# ==============================================================================

output "instance_id" {
  description = "MANDATORY: ID der Drawio-VM für das Backend-Management"
  value       = var.use_mock_provider ? "mock-instance-${var.deployment_id}" : openstack_compute_instance_v2.drawio_server[0].id
}

output "app_name" {
  description = "MANDATORY: Name der Anwendung für das Backend-Management"
  value       = var.app_name
}

# ==============================================================================
# USER OUTPUTS
# ==============================================================================

output "drawio_url" {
  description = "Draw.io Web-Oberfläche"
  value       = var.use_mock_provider ? "http://mock-ip:8080" : "http://${openstack_networking_floatingip_v2.drawio_fip[0].address}:8080"
}

output "ssh_command" {
  description = "SSH-Befehl für den VM-Zugang"
  value       = var.use_mock_provider ? "ssh ubuntu@mock-ip" : "ssh -i <private_key> ubuntu@${openstack_networking_floatingip_v2.drawio_fip[0].address}"
}

output "ssh_private_key" {
  description = "SSH Private Key für den VM-Zugang"
  sensitive   = true
  value       = tls_private_key.drawio_ssh_key.private_key_openssh
}
