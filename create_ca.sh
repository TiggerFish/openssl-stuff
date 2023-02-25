#!/bin/bash
#
#
source ./openssl_vars
#
#

# Creates the working directory if it doesn't exist.
if [ ! -d $WORKDIR ]; then
  mkdir -p $WORKDIR
fi
cat << EOF > $WORKDIR/openssl.cnf
#
[ ca ]
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = $WORKDIR
certs             = $WORKDIR
new_certs_dir     = $WORKDIR/newcerts
database          = $WORKDIR/index.txt
serial            = $WORKDIR/serial
RANDFILE          = $WORKDIR/.rand
copy_extensions   = copy

# The root key and root certificate.
private_key       = $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.key
certificate       = $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.crt


# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_loose

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
prompt	            = no

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = $CCODE
stateOrProvinceName             = $MYST
localityName                    = $MYLOC
0.organizationName              = $MYORG
organizationalUnitName		= $MYOU
commonName                      = $SRVCN

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ server_cert ]
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment
extendedKeyUsage = serverAuth,clientAuth

EOF

#Creates database file
touch $WORKDIR/index.txt
#Creates newcerts dir
mkdir $WORKDIR/newcerts

#Create CA Private key
openssl genrsa -out $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.key 4096
chmod 400 $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.key

#Create CA Cert
openssl req -config $WORKDIR/openssl.cnf -key $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.key -new -x509 -days 7300 -sha256 -extensions v3_ca -out $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.crt \
  -subj "/C=$CCODE/ST=$MYST/L=$MYLOC/O=$MYORG/OU=$MYOU/CN=$ROOTCN"
chmod 444 $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.crt

# Check CA cert
#openssl x509 -noout -text -in $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.crt
