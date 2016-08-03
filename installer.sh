#!/bin/bash
sudo mkdir /etc/efwat
# copy the token fetcher script into the working directory
cp token_fetcher.sh /etc/efwat/token_fetcher.sh
cd /etc/efwat

while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -i|--interface)
    INTERFACE_PARAM="$2"
    shift # past argument
    ;;
    -s|--serveradress)
    SERVER_PARAM="$2"
    shift # past argument
    ;;
    *)
    # unknown option
    ;;
esac
shift
done

TODATE="$(date +%Y)-$(date +%m)-$(date +%d)"

SCRIPTLOG=runlog

if [ -f $SCRIPTLOG ] ; then
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
else
echo "$TODATE [$(date +%T)]: Logfile created" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
fi

# Create Host and Random password

if [ -z "$INTERFACE_PARAM" ]; then
    INTERFACE=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1 {split($2,a," ");pri$
else
    INTERFACE=$INTERFACE_PARAM
fi

if [ -z "$SERVER_PARAM" ]; then
    SERVER=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1 {split($2,a," ");pri$
else
    SERVER="http://efwatns1.kannita.com:3000/"
fi

echo "$TODATE [$(date +%T)]: Working with device interface $INTERFACE" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: Working with server $SERVER" >> $SCRIPTLOG

HOST=$(sudo cat /sys/class/net/$INTERFACE/address | tr : -)
PASS=$(date| sha256sum | base64 | head -c 32)
IP=$(ifconfig $INTERFACE | awk '/inet addr/{print substr($2,6)}')

echo "$TODATE [$(date +%T)]: * Device Current IP $IP" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Mac address : $HOST" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Password Has Been Generated" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Registering Device To efwhat Service" >> $SCRIPTLOG

curl -k -X POST $SERVER/register -d host=$HOST -d pass=$PASS

# run script to get token and store it in token file

echo "$TODATE [$(date +%T)]: * Token Been Received" >> $SCRIPTLOG

TOKEN=$(sudo bash token_fetcher.sh $HOST $PASS)

echo "$TODATE [$(date +%T)]: * Registering device to efwhat dns" >> $SCRIPTLOG

# register device ip to efwat service
curl -k -X POST $SERVER/api/update -d host=$HOST -d newIp=$IP -d token=$TOKEN

echo "$TODATE [$(date +%T)]: * Installing Ip checker daemon" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Ensuring DHCP hooks" >> $SCRIPTLOG
echo "ip : $IP , token : $TOKEN, host;$HOST, pass:$PASS"

echo "TOKEN=$TOKEN" >> config
echo "SERVER=$SERVER" >> config
echo "PASS=$PASS" >> config
echo "INTERFACE=$INTERFACE" >> config

# Append the ip-checker to the dhcp hooks
if [ ! -f /etc/dhclient-exit-hooks]; then
    echo "$TODATE [$(date +%T)]: * DHCP hooks exits on machine, appending daemon to script" >> $SCRIPTLOG
    echo "sudo bash /etc/efwat/ip-checker.sh" >> /etc/dhclient-exit-hooks
else
    echo "$TODATE [$(date +%T)]: * DHCP hooks not exits on machine, creating new exit hook" >> $SCRIPTLOG
    sudo touch /etc/dhclient-exit-hooks
    chmod +x /etc/dhclient-exit-hooks
    echo "sudo bash /etc/efwat/ip-checker.sh" >> /etc/dhclient-exit-hooks
fi







