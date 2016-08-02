(function(){
    var Route53     = require('nice-route53')

    var ACCESS_KEY_ID = "AKIAIHOAYKK7NBEOIEKA";
    var SECRET_ACCESS_KEY = "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";

    var r53 = new Route53({
        accessKeyId : ACCESS_KEY_ID ,
        secretAccessKey : SECRET_ACCESS_KEY
    });

    var efWhatZoneId = "Z1E4WBTW4XVKBE";
    // if needed to work with dynamic ids

    /*function getZoneId(){
       return new Promise(function(resolve,error){
           r53.zoneInfo('Z1E4WBTW4XVKBE', function(err, zoneInfo) {
               if(err) {
                   resolve({err:err});
                   return;
               }

               console.log('got zone id',zoneInfo.zoneId);
               resolve(zoneInfo.zoneId);
           });
       })
    }*/

    /*getZoneId()
     .then(function(res) {
     if(res.err){
     console.log('error occurred while getting zone id ',res.err);
     }
     efWhatZoneId = res.zoneId;
     });*/

    function doUpdateRecord(hostName,newIp){

        return new Promise(function(resolve,error) {

            console.log('updating record %s with new ip %s',hostName,newIp);

            if(hostName.indexOf("efwat.com") == -1){
                hostName += ".efwat.com";
            }



            var args = {
                zoneId: efWhatZoneId,
                name: hostName,
                type: 'A',
                ttl: 86400,
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

                resolve({success:true});
            });
            console.log('updating record %s with new ip %s',hostName,newIp);

            if(hostName.indexOf("efwat.com") == -1){
                hostName += ".efwat.com";
            }

            var args = {
                zoneId: efWhatZoneId,
                name: hostName,
                type: 'A',
                ttl: 86400,
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

                resolve({success:true});
            });
        });
    }

    function updateIpRecord(hostName,newIp){
        /*if(efWhatZoneId == "-1") {
            getZoneId()
            .then(function(res){
                if(res.err){
                    console.log('error occurred while getting zone id ',res.err);
                    return res.err;
                }

                efWhatZoneId = res.zoneId;
                return doUpdateRecord(hostName,newIp);
            })
        }*/

        return doUpdateRecord(hostName,newIp);
    }

    module.exports = {
        updateIpRecord : updateIpRecord
}
})()


