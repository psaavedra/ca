#! /bin/bash

if [ $# -eq 0 ] ; then
	echo "Usage: $0 ca_configuration.cfg client_id client_cn client_passwd"
	exit 1
fi
. $1 

cert_to_create=$2
cert_passwd=$4
set -x
KEY_CN=$3
KEY_DIR=$KEY_DIR/$CA_NAME

cd $KEY_DIR
openssl req -days 3650 -batch -new -keyout $KEY_DIR/$cert_to_create.key -out $KEY_DIR/$cert_to_create.csr -passout pass:"$cert_passwd" -config $KEY_CONFIG
openssl ca -days 3650 -batch -out $KEY_DIR/$cert_to_create.crt -in $KEY_DIR/$cert_to_create.csr -config $KEY_CONFIG
openssl pkcs12 -export -passout pass:"$cert_passwd" -inkey $cert_to_create.key -passin pass:"$cert_passwd" -in $cert_to_create.crt -certfile ca.crt -out $cert_to_create.p12
cp $cert_to_create.p12 "$KEY_CN.p12"
