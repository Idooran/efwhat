(function(){
    const exec = require('child_process').exec;

    function updateIpRecord(hostName,newIp){

        // run script locally as a child process with the above params
        return new Promise(function(resolve,reject){
            exec('ip-updater.sh' + newIp+ ' ' + hostName, (err, stdout, stderr) => {
                var res = {};

                if (err) {
                    // TODO : HANDLER ERROR
                    console.error(err);
                    res.error = err;
                }

                console.log(stdout);
                res.data = stdout;

                resolve(res)
            });
        })

    }

    module.exports = {
        updateIpRecord : updateIpRecord
}
})()


