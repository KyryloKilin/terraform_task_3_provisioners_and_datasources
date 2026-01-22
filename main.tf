resource "null_resource" "nginx" {
  triggers = {
    vm_id     = data.azurerm_virtual_machine.main.id
    page_sha1 = filesha1(var.local_default_page)
  }

  lifecycle {
    precondition {
      condition     = local.host_ip != null
      error_message = "NIC has no Public IP attached. Attach a Public IP to ${var.prefix}-nic so Terraform can SSH into the VM."
    }
  }

  connection {
    type     = "ssh"
    host     = local.host_ip
    user     = var.admin_username
    password = var.admin_password
    timeout  = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable --now nginx"
    ]
  }

  provisioner "file" {
    source      = var.local_default_page
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/index.html /var/www/html/index.nginx-debian.html",
      "sudo chmod 644 /var/www/html/index.nginx-debian.html",
      "sudo systemctl reload nginx"
    ]
  }
}

output "public_ip" {
  value = local.host_ip
}

output "nginx_url" {
  value = local.host_ip == null ? null : "http://${local.host_ip}"
}
