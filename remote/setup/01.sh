#!/bin/bash
set -eu
#=======================================================
# VARIABLES
#=======================================================
TIMEZONE=Asia/Kolkata
USERNAME=greenlight
read -p "Enter password for greenlight DB user: " DB_PASSWORD
export LC_ALL=en_US.UTF-8

#=======================================================
# SCRIPT LOGIC
#=======================================================
# Enable the "universe" repository
add-apt-repository --yes universe
apt update
apt --yes -o Dpkg::Options::="--force-confnew" upgrade

# Set the system timezone and install all locales.
timedatectl set-timezone ${TIMEZONE}
apt --yes install locales-all

# Add the new user (and give them sudo privileges).
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"

# Force a password to be set for the new user the first time they log in
passwd --delete "${USERNAME}"
chage --lastday 0 "${USERNAME}"

# Copy the SSH keys from the root user to the new user.
rsync --archive --chown=${USERNAME}:${USERNAME} /root/.ssh /home/${USERNAME}

# Configure the firewall to allow SSH, HTTP and HTTPS traffic
ufw allow 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# INstall fail2ban
apt --yes install fail2ban

# Install the migrate CLI tool.
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

mv migrate.linux-amd64 /usr/local/bin/migrate

apt --yes install postgresql
# Set up the greenlight DB and create a user account with the password entered earlier
sudo -i -u postgres psql -c "CREATE DATABASE greenlight"
sudo -i -u postgres psql -d greenlight -c "CREATE EXTENSION IF NOT EXISTS citext"
sudo -i -u postgres psql -d greenlight -c "CREATE ROLE greeenlight WITH LOGIN PASSWORD '${DB_PASSWORD}'"

# Add a DSN for connecting to the greenlight database to the system-wide environment
echo "GREENLIGHT_DB_DSN='postgres://greenlight:${DB_PASSWORD}@localhost/greenlight'" >> /etc/environment

# Install Caddy

apt --yes install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt --yes install caddy

echo "Script complete! Rebooting..."
reboot