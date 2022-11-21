# openssl-stuff

### **create_ca_and_cert_with_san.sh**  
An easy way to create a CA cert and a signed server/client cert with a SAN. This script doesn't pretend to create a secure CA but it is a quick way to get a CA signed server/client cert with a SAN that can be used for testing purposes.  
**Usage**  
Update the VARS at the top of the file and run it. Everything with me created in the working directory $WORKDIR  
I hope the comments on the VARS are self explanatory  
CCODE=GB &emsp; #countryName  
MYST=England &emsp; #stateOrProvinceName  
MYLOC=London &emsp; #localityName  
MYORG=Acme &emsp; #0.organizationName  
MYOU=IT &emsp; #organizationalUnitName  
ROOTCN="Acme Root CA" &emsp; #Root CA CommonName  
SRVCN="test.lab.home" &emsp; #Server CommonName  
WORKDIR=$(pwd)/certs &emsp; #Working directory where everything gets created  

### ***create a self signed cert with a SAN*** ###  
openssl req -newkey rsa:4096 -nodes -sha256 -keyout test.lab.home.key -x509 -days 365 -out test.lab.home.crt -addext "subjectAltName = DNS:test.lab.home" -subj CN=/test.lab.home  
