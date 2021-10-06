#!/bin/bash
# lab3
myhostname=$(hostname)
ethernet_adptname=$( ip a |awk '/: e/{gsub(/:/,"");print $2 }')
local_ipaddress=$( ip a s $ethernet_adptname | awk '/inet /{gsub(/\/.*/,"");print $2}')
local_ipaddress_hosts=$( getent hosts $local_ipaddress | awk '{print $2}')
public_ip=$(curl -s icanhazip.com)
external_name=$(getent hosts $public_ip | awk '{print $2}')
router_address=$(route -n |grep 'UG[ \t]' | awk '{print $2}')
router_hostname=$(route |grep "default" | awk '{print $2}')

cat <<EOF
Hostname        : $myhostname
LAN Address     : $local_ipaddress
LAN Hostname    : $local_ipaddress_hosts
External IP     : $public_ip
External Name   : $external_name
Router Address  : $router_address
Router Hostname : $router_hostname
EOF

