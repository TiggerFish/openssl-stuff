#!/bin/bash
#
#
source ./openssl_vars
#
#

# Create Server key
openssl genrsa -out $WORKDIR/$1.key 2048

# Create Server CSR
openssl req -config $WORKDIR/openssl.cnf -addext "subjectAltName = DNS:$1" -subj /CN=$1 -key $WORKDIR/$1.key -new -sha256 -out $WORKDIR/$1.csr

# Sign Server CSR
openssl ca -batch -create_serial -config $WORKDIR/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in $WORKDIR/$1.csr -out $WORKDIR/$1.crt
chmod 444 $WORKDIR/$1.crt
