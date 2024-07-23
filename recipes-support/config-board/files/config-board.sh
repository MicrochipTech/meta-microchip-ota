#! /bin/sh
serial=`p11tool --info "pkcs11:token=MCHP;object=device;type=private" | sed -ne 's|.*serial=\(.*\);token.*|\1|p'`
hostname=`hostname`
cert_path="/etc/swupdate"

sed -i "s|$hostname|$hostname-$serial|" /etc/hosts

# for systemd and the main image, set the hostname with hostnamectl, if initramfs use hostname command
if command -v hostnamectl &> /dev/null; then
        hostnamectl hostname $hostname-$serial
else
        hostname $hostname-$serial
fi

# set id attribute to ECC608 serial number in /etc/swupdate.cfg
sed -i "/suricatta :/,/};/s/\tid\t\t=.*/\tid\t\t= \"$serial\";/" /etc/swupdate.cfg

# set serial number in identify block of swupdate.cfg
sed -i "/identify : (/,/);/s/default_serial/$serial/" /etc/swupdate.cfg

# set the mTLS certificate in /etc/swupdate.cfg
sed -i "s|.*sslcert.*|\tsslcert\t\t= \"$cert_path/$serial.crt\";|g" /etc/swupdate.cfg
