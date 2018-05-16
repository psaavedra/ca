
## Installation

```
mkdir /var/lib/ca/
cd /var/lib/ca/
git clone https://github.com/psaavedra/ca.git acme
cd acme
cp conf/ca_demo.cfg  conf/ca_coyote.cfg 
```


## Configuration

* edit `/var/lib/ca/acme/conf/ca_coyote.cfg`

```
export CA_NAME=coyote
export CA_EXPIRE=3650
export KEY_SIZE=2048
export KEY_CONFIG=/var/lib/ca/acme/conf/openssl-ca.cnf
export KEY_DIR=/var/lib/ca/acme/keys
export KEY_COUNTRY=ES
export KEY_PROVINCE=Coruna
export KEY_CITY="A Coruna"
export KEY_ORG=Acme
export KEY_EMAIL=support@acme.com
export KEY_CN=Acme CA
export KEY_OU=Acme Systems
```

## CA creation

```
cd /var/lib/ca/acme/
./bin/create_ca.sh conf/ca_coyote.cfg

ls keys/coyote/
ca.crt  ca.key  ca.pem  crlnumber  crlnumber.old  crl.pem  dh2048.pem  index.txt  index.txt.attr  serial
```

## Server side certificate creation

```
./bin/create_server_cert.sh conf/ca_coyote.cfg service1 service1.acme.local mysecretpassphrase 
# ...
countryName           :PRINTABLE:'ES'
stateOrProvinceName   :PRINTABLE:'Coruna'
localityName          :PRINTABLE:'A Coruna'
organizationName      :PRINTABLE:'Acme'
organizationalUnitName:PRINTABLE:'Acme'
commonName            :PRINTABLE:'service1.acme.local'
emailAddress          :IA5STRING:'support@acme.com'
```

```
ls keys/coyote/pr*
keys/coyote/service1.crt  keys/coyote/service1.acme.local.crt  keys/coyote/service1.acme.local.p12     keys/coyote/service1.key
keys/coyote/service1.csr  keys/coyote/service1.acme.local.key  keys/coyote/service1.acme.local.server  keys/coyote/service1.p12
```

The passphrase only is applied in the p12 exportable file. The certificate and
the pricate key are ready to deploy a nginx or apache2 server without password.


## Client certificate creation

```
./bin/create_client_cert_no_password.sh conf/ca_coyote.cfg client1 client1.acme.local
# ...
countryName           :PRINTABLE:'ES'
stateOrProvinceName   :PRINTABLE:'Coruna'
localityName          :PRINTABLE:'A Coruna'
organizationName      :PRINTABLE:'Acme'
organizationalUnitName:PRINTABLE:'Acme'
commonName            :PRINTABLE:'client1.acme.local'
emailAddress          :IA5STRING:'support@acme.com'
```

```
ls keys/coyote/pan*
keys/coyote/client1.crt  keys/coyote/client1.csr  keys/coyote/client1.acme.local.p12  keys/coyote/client1.key  keys/coyote/client1.p12
```


## Using CA, server and client certificates in a Nginx server

```
# HTTPS server
server {
    listen 443;
    server_name service1.acme.local;

    root /var/www/service1;
    index index.html index.htm;

    ssl on;
    ssl_certificate     /var/lib/ca/acme/keys/coyote/service1.crt;
    ssl_certificate_key /var/lib/ca/acme/keys/coyote/service1.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    ssl_prefer_server_ciphers on;
    ssl_dhparam /var/lib/ca/acme/keys/coyote/dh2048.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 5m;

    ssl_client_certificate /var/lib/ca/acme/keys/coyote/ca.crt;
    ssl_verify_client on;
    ssl_crl /var/lib/ca/acme/keys/coyote/crl.pem;

    location / {
        try_files $uri $uri/ =404;
        # rewrite ^/$ /index.html?verified=$ssl_client_verify redirect;
    }
}
```

In this simple example, we have configured nginx to use the server certificates
previously generated for encryption of the secure channel:

```
ssl on;
ssl_certificate     /var/lib/ca/acme/keys/coyote/service1.crt;
ssl_certificate_key /var/lib/ca/acme/keys/coyote/service1.key;
```

We have established a reasonably secure SSL configuration. Also using the DH
file of the CA:

```
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
ssl_prefer_server_ciphers on;
ssl_dhparam /var/lib/ca/acme/keys/coyote/dh2048.pem;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 5m;
```

Finally, we have configured authentication with client certificate and with
certificate revocation:

```
ssl_verify_client on;
ssl_client_certificate /var/lib/ca/acme/keys/coyote/ca.crt;
ssl_crl /var/lib/ca/acme/keys/coyote/crl.pem;
```

You can verify easily the client certificate is working with the
following configuration:

```
ssl_verify_client optional;
# ...
location / {
    try_files $uri $uri/ =404;
    rewrite ^/$ /index.html?verified=$ssl_client_verify redirect;
# $ssl_client_verify;
# $ssl_client_s_dn;
# $ssl_client_cert;
}
```

With this configuration, client authentication is optional. If the client uses
a valid certificate, then the value of the 'verified' parameter will be True in
the redirection made in the '/' location, False otherwise.

This check can be easily done installing the client certificate
in any browser using the file in exportable format p12. It will also
be necessary to import the ca.crt file from the certificate authority.
