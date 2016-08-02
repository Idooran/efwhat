
#!/bin/bash
# Script that updates the meta information for the referring, public-viewable HTML page

# 1. check if IP changed since last update
# 2. If not, die
# 3. if it has, upload new HTML file.

TODATE="$(date +%Y)-$(date +%m)-$(date +%d)"
# DEBUG
SCRIPTLOG= /etc/efwat/runlog

cd /etc/efwat/

if [ -f $SCRIPTLOG ] ; then
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
else
echo "$TODATE [$(date +%T)]: Logfile created" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
fi

echo $(ifconfig | grep inet) > newip

SERVER < ipConfServer

NEWIP=$(cut -f2 -d' ' newip)
NEWIP=${NEWIP##addr:}
OLDIP=$(cut -f2 -d' ' oldip)
OLDIP=${OLDIP##addr:}

echo "$TODATE [$(date +%T)]: * Previous IP: $OLDIP" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Current  IP: $NEWIP" >> $SCRIPTLOG

if [ ! "$NEWIP" == "$OLDIP" ] ; then
    echo "new ip has changed" >> $SCRIPTLOG
    TOKEN=$(cat token)
    HOST=$(cat host)
    echo "$TODATE [$(date +%T)]: * Sending IP ip update to efwat" >> $SCRIPTLOG
    curl -k -X POST http://efwatns1.kannita.com:3000/api/update -d host=$HOST -d newIp=$NEWIP -d token=$TOKEN
    # if token is out of date then first get a new token and then do the action
fi

rm oldip
mv newip oldip
echo "$TODATE [$(date +%T)]: Finished: updateip" >> $SCRIPTLOG
