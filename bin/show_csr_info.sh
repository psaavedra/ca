#! /bin/bash
CSR=$1
set -x
openssl req -in $CSR -noout -text
