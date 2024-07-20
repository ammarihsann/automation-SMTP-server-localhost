#!/bin/bash

# Backup file /etc/hosts
cp /etc/hosts /etc/hosts.bak

# Ubah entri di dalam /etc/hosts
sed -i 's/127.0.1.1 smofi.com smofi/192.168.100.88 smofi.com smofi/' /etc/hosts

echo "Entri telah diubah."
