resource "hcloud_server" "cloud" {
  count       = var.instances
  name        = "hcloud-server-bitwarden"
  image       = var.os_type
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels = {
    type = "hcloud"
  }
  user_data = file("user_data.yml")
}
