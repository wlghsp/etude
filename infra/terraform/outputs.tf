output "public_ip" {
  value = oci_core_public_ip.etude.ip_address
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/etude_oci ubuntu@${oci_core_public_ip.etude.ip_address}"
}