#! /bin/sh
serial=`p11tool --info "pkcs11:token=MCHP;object=device;type=private" | sed -ne 's|.*serial=\(.*\);token.*|\1|p'`
cert_path="/etc/swupdate"
hostname="hostname"
domain="domain"

openssl req -engine pkcs11 -key "pkcs11:token=MCHP;object=device;type=private" -keyform engine -new -out /tmp/$serial.csr.pem -subj "/CN=$serial"

curl -F csr=@/tmp/$serial.csr.pem https://$hostname.$domain/provisioning/index.php -o $cert_path/$serial.crt
