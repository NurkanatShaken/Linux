#!/bin/bash

ZABBIX_SERVER_IP="*.*.*.*"
HOSTNAME="*****"
# Установка Zabbix Agent 2
echo "Installing Zabbix Agent 2..."

sudo wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_7.0-1+ubuntu22.04_all.deb

sudo apt update && sudo apt install -y zabbix-agent2 zabbix-agent2-plugin-postgresql

# Настройка Zabbix Agent 2

echo "Configuring Zabbix Agent 2..."
sudo sed -i "s/^Server=127.0.0.1/Server=$ZABBIX_SERVER_IP/" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/^ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER_IP/" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/^Hostname=Zabbix server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agent2.conf

# Перезапуск Zabbix Agent 2
sudo systemctl restart zabbix-agent2 && sudo systemctl enable zabbix-agent2

# Проверка статуса Zabbix Agent 2
echo "Checking Zabbix Agent 2 status..."
sudo systemctl status zabbix-agent2
