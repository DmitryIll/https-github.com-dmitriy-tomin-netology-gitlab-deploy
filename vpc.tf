resource "yandex_vpc_network" "netology-gitlab-net" {
  name = "gitlab-net"
}

resource "yandex_vpc_subnet" "netology-gitlab-sub" {
  name           = "gitlab-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology-gitlab-net.id
  v4_cidr_blocks = ["10.240.1.0/24"]
}
