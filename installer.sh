sudo mkdir /etc/efwat
# copy the token fetcher script into the working directory
cp token_fetcher.sh /etc/efwat/token_fetcher.sh
cd /etc/efwat

TODATE="$(date +%Y)-$(date +%m)-$(date +%d)"

SCRIPTLOG=runlog

if [ -f $SCRIPTLOG ] ; then
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
else
echo "$TODATE [$(date +%T)]: Logfile created" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
fi

# Create Host and Random password
sudo cat /sys/class/net/eth0/address | tr : - > host

HOST=$(cat host)

date| sha256sum | base64 | head -c 32 > pass

PASS=$(cat pass)

echo "$TODATE [$(date +%T)]: * Mac address : $HOST" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Password Has Been Generated" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Registering Device To efwhat Service" >> $SCRIPTLOG

curl -k -X POST http://efwatns1.kannita.com:3000/register -d host=$HOST -d pass=$PASS

# run script to get token and store it in token file

sudo bash token_fetcher.sh $HOST $PASS

echo "$TODATE [$(date +%T)]: * Token Been Received" >> $SCRIPTLOG

TOKEN=$(cat token)

interface=$(ip route get 8.8.8.8 | awk -F"dev " 'NR==1 {split($2,a," ");print a[1]}')

IP=$(ifconfig $interface | awk '/inet addr/{print substr($2,6)}')

echo "$TODATE [$(date +%T)]: * Device Current IP $IP" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Registering device to efwhat dns" >> $SCRIPTLOG

# register device ip to efwat service
curl -k -X POST http://efwatns1.kannita.com:3000/api/update -d host=$HOST -d newIp=$IP -d token=$TOKEN

echo "$TODATE [$(date +%T)]: * Installing Ip checker daemon" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Ensuring DHCP hooks" >> $SCRIPTLOG
echo "ip : $IP , token : $TOKEN, host;$HOST, pass:$PASS"

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







