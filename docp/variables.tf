variable "ssh_public_key" {
    description = "Public key"
    type = string
    default = "../creds/tester.pub"
}

variable "do_token" {
    description = ""
}

variable "region" {
    description = "Digital Ocean Region"
    default = "nyc1"
}

variable "username" {
    description = "Username"
    type = string
    default = "tester"
}

variable "vps_number" {
    description = "Number of VPS servers"
    type = string
    default = 1
}