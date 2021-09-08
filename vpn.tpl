#Phase 1

set vpn ipsec ike-group FOO0 key-exchange ikev2
set vpn ipsec ike-group FOO0 ikev2-reauth ‘no’
set vpn ipsec ike-group FOO0 lifetime 3600
set vpn ipsec ike-group FOO0 proposal 1 dh-group 2
set vpn ipsec ike-group FOO0 proposal 1 encryption aes256gcm128
set vpn ipsec ike-group FOO0 proposal 1 hash sha1
set vpn ipsec ike-group FOO0 dead-peer-detection action restart
set vpn ipsec ike-group FOO0 dead-peer-detection interval 15
set vpn ipsec ike-group FOO0 dead-peer-detection timeout 30
# eSP phase 2
set vpn ipsec esp-group FOO0 lifetime 3600
set vpn ipsec esp-group FOO0 pfs enable
set vpn ipsec esp-group FOO0 proposal 1 encryption aes256gcm128
set vpn ipsec esp-group FOO0 proposal 1 hash sha1




set vpn ipsec site-to-site peer ${tunnel_ip1} authentication mode pre-shared-secret
set vpn ipsec site-to-site peer ${tunnel_ip1} authentication pre-shared-secret ${shared_secret}
set vpn ipsec site-to-site peer ${tunnel_ip1} connection-type initiate
set vpn ipsec site-to-site peer ${tunnel_ip1} description ipsec-gcp
set vpn ipsec site-to-site peer ${tunnel_ip1} local-address 62.30.17.242

set vpn ipsec site-to-site peer ${tunnel_ip1} ike-group FOO0
set vpn ipsec site-to-site peer ${tunnel_ip1} vti bind vti0
set vpn ipsec site-to-site peer ${tunnel_ip1} vti esp-group FOO0



set vpn ipsec site-to-site peer ${tunnel_ip2} authentication mode pre-shared-secret
set vpn ipsec site-to-site peer ${tunnel_ip2} authentication pre-shared-secret ${shared_secret}
set vpn ipsec site-to-site peer ${tunnel_ip2} connection-type initiate
set vpn ipsec site-to-site peer ${tunnel_ip2} description ipsec-aws
set vpn ipsec site-to-site peer ${tunnel_ip2} local-address 62.30.17.242

set vpn ipsec site-to-site peer ${tunnel_ip2} ike-group FOO0
set vpn ipsec site-to-site peer ${tunnel_ip2} vti bind vti1
set vpn ipsec site-to-site peer ${tunnel_ip2} vti esp-group FOO0


set interfaces vti vti0 address 169.254.0.2/30
set interfaces vti vti1 address 169.254.1.2/30 




#BGP

set policy prefix-list BGP rule 10 action deny
set policy prefix-list BGP rule 10 description deny-localgw
set policy prefix-list BGP rule 10 prefix 62.30.17.242/32

set policy prefix-list BGP rule 20 action deny
set policy prefix-list BGP rule 20 description deny-remotegw1
set policy prefix-list BGP rule 20 prefix ${tunnel_ip1}/32

set policy prefix-list BGP rule 30 action deny
set policy prefix-list BGP rule 30 description deny-remotegw2
set policy prefix-list BGP rule 30 prefix ${tunnel_ip2}/32

set policy prefix-list BGP rule 100 action permit
set policy prefix-list BGP rule 100 description permit-localsubnet
set policy prefix-list BGP rule 100 prefix 192.168.4.0/24

set policy prefix-list BGP rule 110 action permit
set policy prefix-list BGP rule 110 description permit-remotesubnet
set policy prefix-list BGP rule 110 prefix 10.0.1.0/24

set policy prefix-list BGP rule 120 action permit
set policy prefix-list BGP rule 120 description permit-remotesubnet2
set policy prefix-list BGP rule 120 prefix 10.0.2.0/24


#peer neighbor

set protocols bgp 64515 timers holdtime 30
set protocols bgp 64515 timers keepalive 10
set protocols bgp 64515 network 192.168.4.0/24

set protocols bgp 64515 neighbor 169.254.0.1 prefix-list export BGP
set protocols bgp 64515 neighbor 169.254.0.1 prefix-list import BGP
set protocols bgp 64515 neighbor 169.254.0.1 remote-as 64514
set protocols bgp 64515 neighbor 169.254.0.1 soft-reconfiguration inbound

set protocols bgp 64515 neighbor 169.254.1.1 prefix-list export BGP
set protocols bgp 64515 neighbor 169.254.1.1 prefix-list import BGP
set protocols bgp 64515 neighbor 169.254.1.1 remote-as 64514
set protocols bgp 64515 neighbor 169.254.1.1 soft-reconfiguration inbound
set protocols bgp 64515 network 192.168.4.0/24


