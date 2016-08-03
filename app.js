var express = require('express');
var morgan      = require('morgan');
var cors        = require('cors');
var bodyParser  = require('body-parser');
var jwt         = require('jsonwebtoken')

var dns         = require('./dns.js');
var User         = require('./user.js')
var security     = require('./security.js');
var configuration = require('./configuration.js')

var app = express();

var PORT = 3000;

var apiRoutes = express.Router();

// route middleware to verify a token
apiRoutes.use(function(req, res, next) {

    // check header or url parameters or post parameters for token
    var token = req.body.token || req.query.token || req.headers['x-access-token'];

    // decode token
    if (token) {

        // verifies secret and checks exp
        jwt.verify(token, app.get('superSecret'), function(err, decoded) {
            if (err) {
                return res.status(403).send();
            } else {
                // if everything is good, save to request for use in other routes
                req.decoded = decoded;
                next();
            }
        });

    } else {

        // if there is no token
        // return an error
        return res.status(403).send({
            success: false,
            message: 'No token provided.'
        });

    }
});

app.set('superSecret',configuration.getKey("SECRET"));

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: false
}));

app.use(morgan('dev'));

app.use('/api',apiRoutes);

app.post('/api/update', function (req, res) {

    var newIp = req.body.newIp;
    var hostName = req.body.host;

    // Update DNS
    dns.updateIpRecord(hostName,newIp)
        .then(function(updateRes){
            if(updateRes.err){
                console.log('error occurred',updateRes.err);
                res.send({error:updateRes.err});
                return;
            }

            res.send({success:true});
        })
});

app.post('/authenticate', function (req, res) {

    User.findOne({
        host: req.body.host
    }, function(err, user) {

        if (err) throw err;

        if (!user) {
            res.status(403).send();
        } else if (user) {

            // check if password matches
            if (security.decrypt(user.password) != req.body.pass) {
                res.status(403).send();
            } else {
                // if user is found and password is right
                // create a token
                var token = jwt.sign(user, app.get('superSecret'), {
                    expiresIn : 1440*100000 // expires never
                });

                // return the information including token as JSON
                res.send(token);
            }

        }

    });
});

app.post('/register', function (req, res) {

    var password = req.body.pass ;
    var host = req.body.host;

    if(host &&  password ){
        User.create({
            host: host,
            password: security.encrypt(password)
        }, function(err,user){
            if(err){
                console.log('error while saving user ')
                res.status(500).end();
            } else {
                console.log('saved')
                res.send({"success":true})
            }
        });
    }
    else {
        res.status(403).send("not all params been mentioned");
    }

});

app.get('/test',function(req,res){
    res.send({test:1});
});

app.listen(PORT, function () {
    console.log('Efwat server is listening on port 3000!');
});

