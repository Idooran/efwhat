
var express = require('express');
var morgan      = require('morgan');
var cors        = require('cors');
var bodyParser  = require('body-parser');
var jwt         = require('jsonwebtoken')
var dns         = require('./dns.js');
var User         = require('./user.js');


var app = express();

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
                return res.json({ success: false, message: 'Failed to authenticate token.' });
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

app.set('superSecret',"hellow");

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: false
}));
// log every request to the console:
app.use(morgan('dev'));
app.use('/api',apiRoutes);

app.post('/api/update', function (req, res) {

    var newIp = req.body.newIp;
    var hostName = req.body.host;

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

app.post('/authenticate', function (req, res) {

    User.findOne({
        name: req.body.name
    }, function(err, user) {

        if (err) throw err;

        if (!user) {
            res.json({ success: false, message: 'Authentication failed. User not found.' });
        } else if (user) {

            // check if password matches
            if (user.password != req.body.password) {
                res.json({ success: false, message: 'Authentication failed. Wrong password.' });
            } else {

                // if user is found and password is right
                // create a token
                var token = jwt.sign(user, app.get('superSecret'), {
                    expiresIn : 1440 // expires in 24 hours
                });

                // return the information including token as JSON
                res.json({
                    success: true,
                    message: 'Enjoy your token!',
                    token: token
                });
            }

        }

    });
});

app.get('/api/users', function (req, res) {

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

app.post('/register', function (req, res) {

    // TODO HASH THIS PART
    var password = req.body.pass ;
    var name = req.body.host;

    if(name &&  password ){
        User.create({
            name: name,
            password: password,
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
});



app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});

