

variable vpc_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable instance_ip {}
variable ipaddr_blocks {}
variable hostname_blocks {}

data "yandex_compute_image" "ubuntu-2204" {
  family = "ubuntu-2204-lts"
}

#=============================GITLAB SERVER =============================

resource "yandex_compute_instance" "netology-gitlab" {
  name = "${var.env_prefix[0]}-server-1"
  platform_id = "standard-v2"
  zone = "ru-central1-b"
  hostname = var.hostname_blocks[0]

  resources {
    cores = 4
    memory = 6
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = "fd89dsd1oshk57psq3h9"    #<----gitlab image from YC marketplace
      size = 25
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.netology-gitlab-sub.id
    nat = true
  }
  metadata = {
    serial-port-enable = 1
    user-data = "${file("meta.txt")}"
  }
}
#=============================RUNNER=============================

resource "yandex_compute_instance" "runner" {
  name = "${var.env_prefix[1]}-server-1"
  platform_id = "standard-v2"
  zone = "ru-central1-b"
  hostname = var.hostname_blocks[1]

  resources {
    cores = 2
    memory = 4
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2204.id
      size = 15
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.netology-gitlab-sub.id
    nat = true
  }
  metadata = {
    serial-port-enable = 1
    user-data = "${file("meta.txt")}"
  }
  provisioner "file" {
    source = "~/netology-gitlab-deploy/runner_sonar_start.sh"   #pay attention here
    destination = "/home/gitlab/runner_sonar_start.sh"          #pay attention here
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/runner_sonar_start.sh",
          "cd ~",
          "~/runner_sonar_start.sh"
    ]
  }
    connection {
      type = "ssh"
      user = "gitlab" 
      private_key = file("~/netology-gitlab-deploy/<set here your ssh private key>")  #pay attention here
      host = self.network_interface[0].nat_ip_address
    }
  }

output "external_ip" {
  description = "The external IP address of the instance"
  value       = yandex_compute_instance.netology-gitlab.*.network_interface.0.nat_ip_address
}
output "external_ip1" {
  description = "The external IP address of the instance"
  value       = yandex_compute_instance.netology-runner.*.network_interface.0.nat_ip_address
}