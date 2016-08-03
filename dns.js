(function(){
    var Route53     = require('nice-route53')
    var configuration = require('./configuration.js')

    var ACCESS_KEY_ID = configuration.getKey("ACCESS_KEY_ID");
    var SECRET_ACCESS_KEY = configuration.getKey("SECRET_ACCESS_KEY");
    var EFWHAT_ZONE_ID = configuration.getKey("EFWHAT_ZONE_ID");

    var r53 = new Route53({
        accessKeyId : ACCESS_KEY_ID ,
        secretAccessKey : SECRET_ACCESS_KEY
    });

    function doUpdateRecord(hostName,newIp){

        return new Promise(function(resolve,error) {

            console.log('updating record %s with new ip %s',hostName,newIp);

            // ensure that the host passed is correct
            hostName = hostName.replace(new RegExp("[^a-zA-Z0-9-]",'g'),"-")

            if(hostName.indexOf("efwat.com") == -1){
                hostName += ".efwat.com";
            }

            var args = {
                zoneId: EFWHAT_ZONE_ID,
                name: hostName,
                type: 'A',
                ttl: 300,
                values: [
                    newIp
                ]
            };

            r53.setRecord(args, function (err, res) {
                console.log('done updating record');

                if(err){
                    resolve({err:err});
                    return;
                }

                resolve({host:hostName,ip:newIp});
            });

        });
    }

    function updateIpRecord(hostName,newIp){
        return doUpdateRecord(hostName,newIp);
    }

    module.exports = {
        updateIpRecord : updateIpRecord
}
})()


