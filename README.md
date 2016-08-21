# efwat
A dynamic IP service for IoT device - connect to your device by host name 
Similar to services like no-ip, but without the registration / auth thing

# Installation 
>client : apt-get install efwat -i <network_interface> -s <server_address> 
  - default sets to active interface and efwat server 

>server : npm install efwat-server

# Usage
>efwat provide a default implemention of a secure DNS wrap of Amazon Route53

efwat consists of client and server side : 

client - a debien package for identifing change in ip address of the device it's been installed on.
  once a change has been detected efwhat updates the server with the new ip. 
+ after installation,a register request is been send to the server
+ the register request pass the device active network interface's mac address as the device host name and generate a random password
+ the server store the the host name and the hased password and return a jwt
+ each device ip update request, the token is being verified 
+ after instaltion the package will make sure once the device recived a new ip, the DNS server will be updated accoringly 
      
server - Recives ip changes and updates the DNS server after client authentication  
+ contains a registration and authentication using jwt
+ updates DNS server - Amazon Route53 API - for any given ip update
    
    







