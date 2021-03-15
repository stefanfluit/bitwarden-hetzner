resource "hcloud_ssh_key" "default" {
  name       = "hetzner_key_bitwarden"
  public_key = file("sshkey")
}
