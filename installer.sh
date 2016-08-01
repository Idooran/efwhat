# this the installer
# should make a get call for our service
# and get a token (this should be a diffrent script) [should be used from the daemon as well once a token is not valid)
# once a token is recived

mkdir /etc/efwat
cd /etc/efwat

TODATE="$(date +%Y)-$(date +%m)-$(date +%d)"
# DEBUG
SCRIPTLOG=runlog

if [ -f $SCRIPTLOG ] ; then
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
else
echo "$TODATE [$(date +%T)]: Logfile created" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
fi


HOST = /sys/class/net/eth0/address | tr : - > host
PASS = date +%s | sha256sum | base64 | head -c 32 > pass

echo "$TODATE [$(date +%T)]: * Mac address : $HOST" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Password Has Been Generated" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Registering Device To efwhat Service" >> $SCRIPTLOG

curl -k -X POST http://efwatns1.kannita.com:3000/register -d host=$1 -d pass=$2

# run script to get token and sotre it in token file
sudo bash token_fetcher.sh HOST PASS

echo "$TODATE [$(date +%T)]: * Token Been Received" >> $SCRIPTLOG

TOKEN < token

IP =  ifconfig eth0 | awk '/inet addr/{print substr($2,6)}' > newIp

echo "$TODATE [$(date +%T)]: * Device Current IP $IP" >> $SCRIPTLOG

curl -k -X POST http://efwatns1.kannita.com:3000/api/update -d host=HOST -d newIp=IP -d token=TOKEN










