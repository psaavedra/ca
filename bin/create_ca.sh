#! /bin/bash

if [ $# -eq 0 ] ; then
	echo "Usage: $0 ca_configuration.cfg"
	exit 1
fi
. $1

if [ ! -f $KEY_CONFIG ]
then
    echo "$KEY_CONFIG doesn't exist or it is not a file"
    exit 1
fi

echo "Common name: $KEY_CN (Example: ca.domain.com)"
set -x
mkdir -p "$KEY_DIR/$CA_NAME"
cd "$KEY_DIR/$CA_NAME"

touch index.txt
echo 01 > serial
echo 01 > crlnumber
echo "unique_subject = yes" > index.txt.attr

KEY_DIR=$KEY_DIR/$CA_NAME


openssl dhparam -out dh$KEY_SIZE.pem $KEY_SIZE
/usr/bin/openssl req -batch -days $CA_EXPIRE -nodes -new -x509 -keyout "ca.key" -out "ca.crt" -config $KEY_CONFIG
cat ca.crt ca.key > ca.pem
/usr/bin/openssl ca  -gencrl -keyfile "ca.key" -cert "ca.crt" -out "crl.pem" -config $KEY_CONFIG
