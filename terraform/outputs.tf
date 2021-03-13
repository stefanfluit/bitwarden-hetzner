output "hcloud_server_status" {
  value = {
    for server in hcloud_server.cloud :
    server.name => server.status
  }
}

output "hcloud_server_ips" {
  value = {
    for server in hcloud_server.cloud :
    server.name => server.ipv4_address
  }
}
