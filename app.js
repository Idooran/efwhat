
var express = require('express');
var morgan      = require('morgan');
var cors        = require('cors');
var bodyParser  = require('body-parser');
var dns         = require('./dns.js');

var app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: false
}));
// log every request to the console:
app.use(morgan('dev'));

app.post('/update', function (req, res) {

    var newIp = req.body.newIp;
    var hostName = req.body.hostName;
    var oldIp = req.body.oldIp;
    var token = req.body.token;

    // DO verfications

    // Update DNS
    dns.updateIpRecord(hostName,newIp)
        .then(function(updateRes){
            if(updateRes.error){
                console.log('error occurred',updateRes.error);
                res.status(500).end();
                return;
            }

            res.send(updateRes.data);
        })
});

app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});