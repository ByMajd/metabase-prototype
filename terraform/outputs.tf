output "public_ip" {
  description = "Public IP address of the Metabase VM"
  value       = azurerm_public_ip.metabase_public_ip.ip_address
}

output "metabase_url" {
  description = "Metabase URL"
  value       = "http://${azurerm_public_ip.metabase_public_ip.ip_address}:3000"
}