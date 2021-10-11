#!/bin/bash

vchecking=$(echo "$@"| grep -e "-v")
if [[ $vchecking = *"-v"* ]] ; then verbose="yes";fi

function singlereport {
# lab3
[ "$verbose" = "yes" ] && echo "Gathering host information"
myhostname=$(hostname)
ethernet_adptname=$( ip a |awk '/: e/{gsub(/:/,"");print $2 }')
local_ipaddress=$( ip a s $interface | awk '/inet /{gsub(/\/.*/,"");print $2}')
local_ipaddress_hosts=$( getent hosts $local_ipaddress | awk '{print $2}')
[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
public_ip=$(curl -s icanhazip.com)
external_name=$(getent hosts $public_ip | awk '{print $2}')
[ "$verbose" = "yes" ] && echo "Identifying default route"
router_address=$(ip r s default| cut -d ' ' -f 3)
router_hostname=$(getent hosts $router_address|awk '{print $2}')

cat <<EOF
Hostname        : $myhostname
LAN Address     : $local_ipaddress
LAN Hostname    : $local_ipaddress_hosts
External IP     : $public_ip
External Name   : $external_name
Router Address  : $router_address
Router Hostname : $router_hostname
EOF
}

function formultiplereport {
interface=$(lshw -class network | awk '/logical name:/{print $3}')
arraylength=${#interface[@]}
for (( i=0; i<${arraylength}; i++ ));
do
  if [[ ${interface[$i]} = lo* ]] ; then continue ; fi
  [ "$verbose" = "yes" ] && echo "Reporting on interface(s): ${interface[$i]}"
  [ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface ${interface[$i]}"
  ipv4_address=$(ip a s ${interface[$i]} | awk -F '[/ ]+' '/inet /{print $3}')
  ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')
  [ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface ${interface[$i]}"
  network_address=$(ip route list dev ${interface[$i]} scope link|cut -d ' ' -f 1)
  network_number=$(cut -d / -f 1 <<<"$network_address")
  network_name=$(getent networks $network_number|awk '{print $1}')
  echo Interface ${interface[$i]}:
  echo ===========
  echo Address         : $ipv4_address
  echo Name            : $ipv4_hostname
  echo Network Address : $network_address
  echo Network Number  : $network_number
  echo Network Name    : $network_name
done
}

while [ $# -gt 0 ]; do
   case $1 in
      -v | --verbose )
       verbose="yes"
         ;;
      * )
      interface=$1
      singlereport
         ;;
  esac
 shift
done
formultiplereport
