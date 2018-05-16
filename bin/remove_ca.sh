#! /bin/bash

if [ $# -eq 0 ] ; then
	echo "Usage: $0 ca_configuration.cfg"
	exit -1
fi
. $1

echo "Common name: $KEY_CN (Example: ca.domain.com)"
set -x
rm -rf "$KEY_DIR/$CA_NAME"
