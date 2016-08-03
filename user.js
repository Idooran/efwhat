

var mongoose = require('mongoose');

mongoose.connect('localhost', 'fwhat');

var Schema = mongoose.Schema;

// set up a mongoose model and pass it using module.exports
module.exports = mongoose.model('User', new Schema({
    password: String,
    host : String,
    token : String
}));
