
#!/bin/bash
# Script that updates the meta information for the referring, public-viewable HTML page

# 1. check if IP changed since last update
# 2. If not, die
# 3. if it has, upload new HTML file.

    TODATE="$(date +%Y)-$(date +%m)-$(date +%d)"
# DEBUG
SCRIPTLOG=/home/ido/scripts/runlog
# RUN IN FOLDER WHERE PERSISTENT DATA CAN BE STORED.
cd /home/ido/scripts

if [ -f $SCRIPTLOG ] ; then
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
else
echo "$TODATE [$(date +%T)]: Logfile created" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: Starting: updateip" >> $SCRIPTLOG
fi

echo $(ifconfig | grep inet) > newip

NEWIP=$(cut -f2 -d' ' newip)
NEWIP=${NEWIP##addr:}
OLDIP=$(cut -f2 -d' ' oldip)
OLDIP=${OLDIP##addr:}

    echo "$TODATE [$(date +%T)]: * Previous IP: $OLDIP" >> $SCRIPTLOG
echo "$TODATE [$(date +%T)]: * Current  IP: $NEWIP" >> $SCRIPTLOG

if [ ! "$NEWIP" == "$OLDIP" ] ; then
echo "<html><head><META HTTP-EQUIV=\"Refresh\" CONTENT=\"0; URL=http://$NEWIP:8080/mediawiki/\"><META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\" /><META HTTP-EQUIV=\"EXPIRES\" CONTENT=\"-1\" /></head><body></body></html>" >> index.html
curl -s -T index.html -u user:password ftp://users.telenet.be
    rm index.html
echo "$TODATE [$(date +%T)]: ==> Updated http://users.telenet.be/manucardoen/index.html" >> $SCRIPTLOG
fi
rm oldip
mv newip oldip
echo "$TODATE [$(date +%T)]: Finished: updateip" >> $SCRIPTLOG
