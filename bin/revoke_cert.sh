#! /bin/bash

if [ $# -eq 0 ] ; then
	echo "Usage: $0 ca_configuration.cfg certificate_id"
	exit 1
fi

. $1 

cert_to_revoke=$2
set -x

KEY_DIR=$KEY_DIR/$CA_NAME
cd $KEY_DIR

openssl ca -revoke "$cert_to_revoke.crt" -config "$KEY_CONFIG"
openssl ca -gencrl -out "$cert_to_revoke.pem" -config "$KEY_CONFIG"
openssl ca -gencrl -out "crl.pem" -config "$KEY_CONFIG"
cat ca.crt "crl.pem" > "revoke-test.pem"
openssl verify -CAfile "revoke-test.pem" -crl_check "$cert_to_revoke.crt"
