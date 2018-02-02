#!/bin/bash
clear
# declare STRING variable
STRING13=""
STRING14="Wallet Configured"
STRING16="Credit to MasterHash for source material: https://github.com/masterhash-us/"
STRING17="Gathering Masternode Data"


#print variable on a screen
echo $STRING16

read -e -p "Configure Masternode? [Y/n]: " mNode


echo $STRING17
echo $STRING1
    if [[ ("$mNode" == "y" || "$mNode" == "Y" || "$mNode" == "") ]]; then
		read -e -p "Server IP Address: " ip
		read -e -p "Masternode Private Key: " key



#Generating Random Passwords
password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
password2=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`


#Create tincoin.conf

echo '
rpcuser='$password'
rpcpassword='$password2'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip='$ip'
bind='$ip':9859
masternodeaddr='$ip'
masternodeprivkey='$key'
masternode=1
' | sudo -E tee ~/.tincoincore/tincoin.conf >/dev/null 2>&1
sudo chmod 0600 ~/.tincoincore/tincoin.conf
echo $STRING14


cd
cd tincoin
if ./tincoin-cli mnsync status; then
echo ""
else
	 tincoin-cli mnsync status
fi


tincoind -daemon

sleep 5


read -p "The next step will issue some commands to help validate, Press any key to continue... " -n1 -s
tincoin-cli startmasternode local false
tincoin-cli masternode status
cd
cd .tincoincore/sentinel
SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py
fi