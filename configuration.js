(function(){
    var fs = require('fs');
    var configuration = JSON.parse(fs.readFileSync('configuration.json', 'utf8'));

    module.exports = {
        getKey:function(key){
            return configuration[key];
        }
    }

})()
