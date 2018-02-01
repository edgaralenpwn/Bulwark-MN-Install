#!/bin/bash
clear
# declare STRING variable
STRING1="Make sure you double check before hitting enter! Only one shot at these!"
STRING2="If you found this helpful, please donate to TIN Donation: "
STRING3="tFN4dBfDtczjGH11o7ps6NYWDczBMzyGBK"
STRING4="Updating system and installing required packages."
STRING5="Switching to Aptitude"
STRING6="Some optional installs"
STRING7="Starting your masternode"
STRING8="Now, you need to finally start your masternode in the following order:"
STRING9="Go to your windows wallet and from the Control wallet debug console please enter"
STRING10="startmasternode alias false <mymnalias>"
STRING11="where <mymnalias> is the name of your masternode alias (without brackets)"
STRING12="once completed please return to VPS and press the space bar"
STRING13=""
STRING14="Wallet Configured"
STRING15="Installing Sentinel"
STRING16="Credit to MasterHash for source material: https://github.com/masterhash-us/"

#print variable on a screen
echo $STRING1

read -e -p "Server IP Address : " ip
read -e -p "Masternode Private Key (e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h # THE KEY YOU GENERATED EARLIER) : " key
read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
read -e -p "Install UFW and configure ports? [Y/n] : " UFW

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

# update package and upgrade Ubuntu
cd
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get install wget nano htop - y
clear
echo $STRING5
sudo apt-get -y install aptitude

#Generating Random Passwords
password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
password2=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`

echo $STRING6
    if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
    cd ~
    sudo aptitude -y install fail2ban
    sudo service fail2ban restart 
    fi
    if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
    sudo apt-get install ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 52543/tcp
    sudo ufw enable -y
    fi

#Install Tincoin Daemon
sudo apt-get install git
git clone https://github.com/tincoinpay/tincoin.git
sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
sudo apt install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install libdb4.8-dev libdb4.8++-dev
sudo apt-get install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
sudo apt-get install libminiupnpc-dev
sudo apt-get install libzmq3-dev
sudo apt-get install libqrencode-dev
cd tincoin
./autogen.sh
./configure
make
tincoind -daemon
clear

#Setting up coin
clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

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
' | sudo -E tee ~/.tincoin/tincoin.conf >/dev/null 2>&1
sudo chmod 0600 ~/.tincoin/tincoin.conf

echo $STRING14
echo $STRING15

cd
cd
cd .tincoincore   
if ./tincoin-cli stop; then
    rm mncache.dat
	rm mnpayments.dat
	./tincoind -daemon -reindex
else
	tincoin-cli stop
	rm mncache.dat
	rm mnpayments.dat
	tincoind -daemon -reindex
fi


python --version
sudo apt-get update
sudo apt-get -y install python-virtualenv
git clone https://github.com/tincoinpay/sentinel.git && cd sentinel
virtualenv ./venv
./venv/bin/pip install -r requirements.txt


#Link Sentinel to tincoin.conf
echo '
# specify path to tincoin.conf or leave blank
# default is the same as TincoinCore
tincoin_conf=$HOME/.tincoincore/tincoin.conf

# valid options are mainnet, testnet (default=mainnet)
network=mainnet
#network=testnet

# database connection details
db_name=database/sentinel.db
db_driver=sqlite
' | sudo -E tee ~/.tincoincore/sentinel/sentinel.conf >/dev/null 2>&1
sudo chmod 0600 ~/.tincoincore/sentinel/sentinel.conf


cd
cd tincoin
if ./tincoin-cli mnsync status; then
echo ""
else
	 tincoin-cli mnsync status
fi


#Starting coin
(crontab -l 2> /dev/null; echo '* * * * * cd /root/.tincoincore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log') | crontab
(crontab -l 2> /dev/null; echo 'cd ~/.tincoincore/sentinel && ./venv/bin/python bin/sentinel.py 2>&1 >> sentinel-cron.log') | crontab
tincoind -daemon

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10
echo $STRING7
echo $STRING13
echo $STRING8
echo $STRING13
echo $STRING9
echo $STRING13
echo $STRING10
echo $STRING13
echo $STRING11
echo $STRING13
echo $STRING12
sleep 120

read -p "Press any key to continue... " -n1 -s
tincoin-cli startmasternode local false
tincoin-cli masternode status

echo $STRING16