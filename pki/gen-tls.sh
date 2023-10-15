#!/bin/bash

rm -f *.key *.crt *.csr

rm -f "ca*"


openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=My CA" -out ca.csr
openssl x509 -days 3650 -req -in ca.csr -signkey ca.key -out ca.crt


rm -f "server1*"
openssl genrsa -out server1.key 2048
openssl req -new -key server1.key -out server1.csr -sha256 -subj "/CN=localhost"
echo subjectAltName = DNS:vault.d8k.lo,DNS:vault,DNS:vault.vault.svc.cluster.local,DNS:vault.vault.svc,DNS:localhost,IP:127.0.0.1 >> server1.cnf
echo extendedKeyUsage = serverAuth >> server1.cnf
openssl x509 -days 3650 -req -in server1.csr -CAkey ca.key -CA ca.crt -out server1.crt -CAcreateserial -extfile server1.cnf

rm -f "consul*"
openssl genrsa -out consul.key 2048
openssl req -new -key consul.key -out consul.csr -sha256 -subj "/CN=localhost"
echo subjectAltName = DNS:consul-consul-server,DNS:consul-consul-server.vault.svc,DNS:consul-consul-server.vault.svc.cluster.local,DNS:server.dc1.consul,DNS:consul,DNS:consul.vault.svc.cluster.local,DNS:consul.vault.svc,DNS:localhost,IP:127.0.0.1 >> consul.cnf
echo extendedKeyUsage = serverAuth,clientAuth >> consul.cnf
openssl x509 -days 3650 -req -in consul.csr -CAkey ca.key -CA ca.crt -out consul.crt -CAcreateserial -extfile consul.cnf
