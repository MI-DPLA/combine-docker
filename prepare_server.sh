apt update
apt install -y docker.io
# Unfortunately recent docker-compose is only available from the github
curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
# When using a system that uses systemd-resolved for DNS, we need
# to symlink the systemd resolv.conf so docker can resolve
# a non-local DNS server
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl enable docker
systemctl start docker
# In order for docker-compose to work, the user you're running as
# needs to be in the docker group
usermod -aG docker $(whoami)
# At this point you need to log out and back in, or restart, so the group change sticks
# Now you can run build.sh
