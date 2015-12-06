#!/usr/bin/env bash

# Attempt to set APP_HOME
# Resolve links: $0 may be a link
PRG="$0"
# Need this for relative symlinks.
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >&-
APP_HOME="`pwd -P`"
cd "$SAVED" >&-

CERTS_DIR="${APP_HOME}/tmp_certs"

mkdir -p "${CERTS_DIR}"

DAYS=2
TEST_PASS=changeit

CA_KEY="${CERTS_DIR}/testRootCA.key"
CA_PEM="${CERTS_DIR}/testRootCA.pem"

rm -f "${CA_KEY}"
rm -f "${CA_PEM}"

# Make new private key
openssl genrsa -out "${CA_KEY}" 2048

# Self sign certificate good for 2 days, regenerate if more testing
# required
openssl req -x509 -new -nodes -key "${CA_KEY}" -days ${DAYS} -out "${CA_PEM}" -batch -subj "/CN=Bogus CA, OU=Bogus, O=Bogus, C=US"

# Make client certificate
CLIENT_KEY="${CERTS_DIR}/client.key"
CLIENT_CSR="${CERTS_DIR}/client.csr"
CLIENT_CRT="${CERTS_DIR}/client.crt"
CLIENT_P12="${CERTS_DIR}/client.p12"
CLIENT_JKS="${CERTS_DIR}/client.jks"

rm -f "${CLIENT_KEY}"
rm -f "${CLIENT_CSR}"
rm -f "${CLIENT_CRT}"
rm -f "${CLIENT_P12}"
rm -f "${CLIENT_JKS}"

openssl genrsa -out "${CLIENT_KEY}" 2048

openssl req -new -key "${CLIENT_KEY}" -out "${CLIENT_CSR}" -batch -subj "/CN=client test cert"

openssl x509 -req -in "${CLIENT_CSR}" -CA "${CA_PEM}" -CAkey "${CA_KEY}" -CAcreateserial -out "${CLIENT_CRT}" -days ${DAYS}

openssl pkcs12 -export -in "${CLIENT_CRT}" -inkey "${CLIENT_KEY}" -chain -CAfile "${CA_PEM}" -name client -out "${CLIENT_P12}" -passout "pass:${TEST_PASS}"

keytool -noprompt -importkeystore -deststorepass "${TEST_PASS}" -destkeystore "${CLIENT_JKS}" -srcstorepass "${TEST_PASS}" -srckeystore "${CLIENT_P12}" -srcstoretype PKCS12 -destkeypass "${TEST_PASS}"


# Make server certificate
SERVER_KEY="${CERTS_DIR}/server.key"
SERVER_CSR="${CERTS_DIR}/server.csr"
SERVER_CRT="${CERTS_DIR}/server.crt"
SERVER_P12="${CERTS_DIR}/server.p12"
SERVER_JKS="${CERTS_DIR}/server.jks"

rm -f "${SERVER_KEY}"
rm -f "${SERVER_CSR}"
rm -f "${SERVER_CRT}"
rm -f "${SERVER_P12}"
rm -f "${SERVER_JKS}"

openssl genrsa -out "${SERVER_KEY}" 2048

openssl req -new -key "${SERVER_KEY}" -out "${SERVER_CSR}" -batch -subj "/CN=server test cert"

openssl x509 -req -in "${SERVER_CSR}" -CA "${CA_PEM}" -CAkey "${CA_KEY}" -CAcreateserial -out "${SERVER_CRT}" -days ${DAYS}

openssl pkcs12 -export -in "${SERVER_CRT}" -inkey "${SERVER_KEY}" -chain -CAfile "${CA_PEM}" -name server -out "${SERVER_P12}" -passout "pass:${TEST_PASS}"

keytool -noprompt -importkeystore -deststorepass "${TEST_PASS}" -destkeystore "${SERVER_JKS}" -srcstorepass "${TEST_PASS}" -srckeystore "${SERVER_P12}" -srcstoretype PKCS12 -destkeypass "${TEST_PASS}"


# Create empty truststore and plug in just CA as only trusted cert
TRUSTSTORE_JKS="${CERTS_DIR}/truststore.jks"

rm -f "${TRUSTSTORE_JKS}"

#cp "${SERVER_JKS}" "${TRUSTSTORE_JKS}"

#keytool -delete -noprompt -alias server -keystore "${TRUSTSTORE_JKS}" -storepass "${TEST_PASS}"

echo "y" | keytool -import -trustcacerts -alias bogus -file "${CA_PEM}" -keystore "${TRUSTSTORE_JKS}" -keypass "${TEST_PASS}" -storepass "${TEST_PASS}"
