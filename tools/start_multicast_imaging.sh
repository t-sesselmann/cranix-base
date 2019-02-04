#!/bin/bash
INTERFACE=$1
IMAGE=$2
mkdir -p /run/oss
echo "$$ ${IMAGE}" >  /run/oss/multicast-imaging
/usr/sbin/udp-sender --nokbd --interface ${INTERFACE} --file ${IMAGE} --min-receivers 1 --min-wait 5 --max-wait 10
rm  /run/oss/multicast-imaging
