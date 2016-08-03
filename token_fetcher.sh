
#should be run with two params : userName and password
# which the user is the device id and password should be randomly created

curl -k -X POST http://efwatns1.kannita.com:3000/authenticate -d host=$1 -d pass=$2

