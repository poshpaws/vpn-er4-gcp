variable ourip {}
variable peer_asn {}
variable my_asn {}
#variable shared_secret {}
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  myIP = chomp(data.http.myip.body)

}
resource "random_string" "shared_secret" {
  length           = 32
  special          = true
  override_special = "_%@"
}

resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  region   = "europe-west2"
  name     = "ha-vpn"
  network  = google_compute_network.network.id
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "external-gateway"
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "An externally managed VPN gateway"
  interface {
    id         = 0
    ip_address = var.ourip
  }
}

resource "google_compute_network" "network" {
  name                    = "network"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network_subnet1" {
  name          = "ha-vpn-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west2"
  network       = google_compute_network.network.id
}

resource "google_compute_subnetwork" "network_subnet2" {
  name          = "ha-vpn-subnet-2"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west2"
  network       = google_compute_network.network.id
}

resource "google_compute_router" "router1" {
  name     = "ha-vpn-router1"
  network  = google_compute_network.network.name
  bgp {
    asn = var.my_asn
  }
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = "ha-vpn-tunnel1"
  region                          = "europe-west2"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = random_string.shared_secret.result
  router                          = google_compute_router.router1.id
  vpn_gateway_interface           = 0
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                            = "ha-vpn-tunnel2"
  region                          = "europe-west2"
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = random_string.shared_secret.result
  router                          = " ${google_compute_router.router1.id}"
  vpn_gateway_interface           = 1
}

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.router1.name
  region     = "europe-west2"
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "router1_peer1" {
  name                      = "router1-peer1"
  router                    = google_compute_router.router1.name
  region                    = "europe-west2"
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = var.peer_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface1.name
}

resource "google_compute_router_interface" "router1_interface2" {
  name       = "router1-interface2"
  router     = google_compute_router.router1.name
  region     = "europe-west2"
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "router1_peer2" {
  name                      = "router1-peer2"
  router                    = google_compute_router.router1.name
  region                    = "europe-west2"
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = var.peer_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.router1_interface2.name
}



output "shared_secret" {
    value = random_string.shared_secret.result
    
}

/* output "ip" {
  value = local.myIP
} */



output "services" {
value = google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[*].ip_address
}

