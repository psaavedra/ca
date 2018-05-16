#! /bin/bash
CERT=$1
set -x
openssl x509 -in $CERT -text -noout
