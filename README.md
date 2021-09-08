# build a vpn link for gcp 
# will spit out a config file to paste into a ER4 router for VPN/BGP setup (might also work with Vyos , but untested)
your going to need a terraform.tfvars like this :

ourip = "xxx.yyy.zzz.aaa"
peer_asn = 64515
my_asn = 64514



site ip address
and any asn you care to use 