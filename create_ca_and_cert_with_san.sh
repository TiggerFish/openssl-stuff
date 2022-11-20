#!/bin/bash
#
#
CCODE=GB			#countryName
MYST=England			#stateOrProvinceName
MYLOC=London			#localityName
MYORG=Acme			#0.organizationName
MYOU=IT				#organizationalUnitName
ROOTCN="Acme Root CA"		#Root CA CommonName
SRVCN="test.lab.home"		#Server CommonName
WORKDIR=$(pwd)/certs		#Working directory where everything gets created
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
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $SRVCN

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

# Create Server key
openssl genrsa -out $WORKDIR/$SRVCN.key 2048

# Create Server CSR
openssl req -config $WORKDIR/openssl.cnf -key $WORKDIR/$SRVCN.key -new -sha256 -out $WORKDIR/$SRVCN.csr

# Sign Server CSR
openssl ca -batch -create_serial -config $WORKDIR/openssl.cnf -extensions server_cert -days 375 -notext -md sha256 -in $WORKDIR/$SRVCN.csr -out $WORKDIR/$SRVCN.crt
chmod 444 $WORKDIR/$SRVCN.crt

# Check Server Cert
openssl x509 -noout -text -in $WORKDIR/$SRVCN.crt

# Check trust in full chain
openssl verify -CAfile $WORKDIR/$(echo "$MYORG" | tr '[:upper:]' '[:lower:]').ca.crt $WORKDIR/$SRVCN.crt

