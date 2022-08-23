variable "num_nodes" {
  type = number
}

variable "nodes_key" {
  type = string
}

variable "nodes_key_name" {
  type = string
}

variable "docker_install_url" {
  default = "https://releases.dev.com/install-docker/18.09.sh"
}
