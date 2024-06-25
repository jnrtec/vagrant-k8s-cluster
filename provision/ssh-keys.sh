#!/bin/bash
# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -q -N ""
# Add public key to authorized keys
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
# Set correct permissions
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
