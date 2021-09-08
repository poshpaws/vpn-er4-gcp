data "template_file" "vpn" {
  template = "${file("${path.module}/vpn.tpl")}"
  vars = {
    shared_secret = random_string.shared_secret.result
    tunnel_ip1 = element(google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[*].ip_address,0)
    tunnel_ip2 = element(google_compute_ha_vpn_gateway.ha_gateway.vpn_interfaces[*].ip_address,1)
  }
}


resource "local_file" "vpnstub" {
    content = data.template_file.vpn.rendered
    filename = "${path.module}/vpn config stub.txt"
}

