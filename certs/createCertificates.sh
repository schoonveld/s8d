#! /bin/bash
cd "$(dirname "$0")" || exit
echo "Checking for existing certificates..."

FILES_EXIST=true;

# checking for password file
if [ -f $HOME/.ssh/s8d.password ]
then
  echo "s8d.password exist"
else
  echo "s8d.password does not exist"
  FILES_EXIST=false;
fi

# checking for CA keyfile
if [ -f $HOME/.ssh/schoonveld-ict_CA.key ]
then
  echo "schoonveld-ict_CA.key exists in $HOME/.ssh"
else
  echo "schoonveld-ict_CA.key does not exist in $HOME/.ssh"
  FILES_EXIST=false
fi

# Checking for s8d.local key file
if [ -f $HOME/.ssh/s8d.key ]
then
  echo "s8d.key exists in $HOME/.ssh"
else
  echo "s8d.key does not exist in $HOME/.ssh"
  FILES_EXIST=false
fi

# Checking for CA pem file
if [ -f ./ca/schoonveld-ict_CA.pem ]
then
  echo "schoonveld-ict_CA.pem exists"
else
  echo "schoonveld-ict_CA.pem does not exist"
  FILES_EXIST=false
fi
# Checking for s8d.local crt file

if [ -f ./s8d/s8d.local.crt ]
then
  echo "s8d.local.crt exists"
else
  echo "s8d.local.crt does not exist"
  FILES_EXIST=false
fi

if [ $FILES_EXIST == true ]
then
  echo "All certificate files exist. Exit!"
  exit 0
fi

echo "Start generating SSL root and domain certificates"
read -rp "Enter a password: " -s password
echo "$password" > $HOME/.ssh/s8d.password

openssl genrsa -passout file:$HOME/.ssh/s8d.password -des3 -out ./ca/schoonveld-ict_CA.key 2048
openssl req -x509 -new -nodes -key ./ca/schoonveld-ict_CA.key -passin file:$HOME/.ssh/s8d.password -sha256 -days 365 -out ./ca/schoonveld-ict_CA.pem -config ./ca/schoonveld-ict_CA.cnf
openssl genrsa -passout file:$HOME/.ssh/s8d.password -out ./s8d/s8d.local.key 2048
openssl req -new -key ./s8d/s8d.local.key -passin file:$HOME/.ssh/s8d.password -out ./s8d/s8d.local.csr -config ./s8d/s8d.local.cnf -extensions v3_req
openssl x509 -req -in ./s8d/s8d.local.csr -CA ./ca/schoonveld-ict_CA.pem -CAkey ./ca/schoonveld-ict_CA.key -passin file:$HOME/.ssh/s8d.password -CAcreateserial -out ./s8d/s8d.local.crt -days 825 -sha256 -extfile ./s8d/s8d.local.cnf -extensions v3_req

