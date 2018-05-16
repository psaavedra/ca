#! /bin/bash

if [ $# -eq 0 ] ; then
	echo "Usage: $0 ca_configuration.cfg"
	exit 1
fi

. $1 

set -x
KEY_DIR=$KEY_DIR/$CA_NAME
cd $KEY_DIR
edit $KEY_DIR/index.txt
openssl ca -gencrl -out "crl.pem" -config "$KEY_CONFIG"
