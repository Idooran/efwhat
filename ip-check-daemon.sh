
server = "localhost/uplodat"

# handle loggin and scedule


# if private lan need to change to local checking , at the meanwhile it is fine
currentIp < wget http://icanhazip.com/

#NET_INTERFACE=eth0
#currentIp =`/sbin/ifconfig $NET_INTERFACE | sed -n "/inet addr:.*255.255.25[0-5].[0-9]/{s/.*inet addr://; s/ .*//; p}"`

oldIp < oldIp.dat

if(currentIp != oldIp){

    token < token.dat
    hostName < hostName.dat

    // do wget with post passing token and host name and new IP to it
    data = "token=" + token + "&hostName=" + hostName + "&newIp=" + currentIp
    wget --post-data=data
}
