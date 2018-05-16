#! /bin/bash

if [ $# -eq 0 ] ; then
	echo "Usage: $0 ca_configuration.cfg server_id server_cn server_pk12_passwd"
	exit 1
fi
. $1 

cert_to_create=$2
cert_passwd=$4

set -x
KEY_CN=$3
KEY_DIR=$KEY_DIR/$CA_NAME
cd $KEY_DIR
echo "Auto. generated" > "$KEY_CN.server"
openssl req -days $CA_EXPIRE -batch -new -keyout $KEY_DIR/$cert_to_create.key -out $KEY_DIR/$cert_to_create.csr -nodes -extensions server -config $KEY_CONFIG 
openssl ca -days $CA_EXPIRE -batch -out $KEY_DIR/$cert_to_create.crt -in $KEY_DIR/$cert_to_create.csr  -extensions server -config $KEY_CONFIG 
openssl pkcs12 -export -passout pass:"$cert_passwd" -inkey $cert_to_create.key -in $cert_to_create.crt -certfile ca.crt -out $cert_to_create.p12
ln -f $cert_to_create.p12 "$KEY_CN.p12"
ln -f $cert_to_create.crt "$KEY_CN.crt"
ln -f $cert_to_create.key "$KEY_CN.key"
