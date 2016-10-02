//var Parse = require('parse/node').Parse;
var Login = require('../models/login');
var Signup = require('../models/signup');
var Promise = require('promise');
var ApplicationMessage = require('../models/message');
var Classes = require('../utils/classes');
var utils = require('../utils/utils');
var Models = require("../models/models");

exports.authenticate = function(req, res, next) {
	if (req.session.user) {
		next();
	} else {
		res.redirect('/app/login');
	}
};

exports.go = function(req, res) {
	res.redirect("/app/dashboard");
};

exports.getLogin = function(req, res) {
    try {
        req.session.user = null;
        Parse.User.logOut();
    } catch (e) {
        // Move on
    }
	var model = new Login();
	var data = { user: { auth: false } };
	model.renderModel(data);
	var session = Object.assign({ }, req.session);
	delete req.session.theErrors;
	res.render("login", { model: model, session: session });
};

exports.postLogin = function(req, res) {
	exports.tryLogin(req.body).then(function(response) {
		if (response.auth) {
            req.session.user = response.user;
            res.redirect('/app/dashboard');
		}
        else if (response.auth == false && response.verify == true) {
            req.session.username = req.body.username;
            res.redirect("/app/verify");
        } else {
			var model = new Login();
			var data = { user: { auth: false } };
			model.renderModel(data);

			var error = new Error();
	        var x = utils.processError(response.error, error, [ req.body.username ]);
	        utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

			var myError = new ApplicationMessage();
			myError.message = x.message;
			myError.isError = true;
			model.page.theErrors.push(myError);
			delete req.session.theErrors;
			res.render("login", { model: model , session: null });
		}
	});
};

exports.tryLogin = function(user) {
	return new Promise(function(fulfill, reject) {
		try {

			Parse.User.logIn(user.username, user.password, {
				success: function(newUser) {
					var verified = newUser.get("verified");
					if (verified == 0)
						fulfill({ auth: false, verify: true  });
					else
						fulfill({ auth: true, user: newUser });
				},
				error: function(sorryUser, error) {
					fulfill({ auth: false , error: error });
				}
			});
		} catch (e) {
			var x = 5;
		}
	});
};

exports.getSignup = function(req, res) {
	var model = new Signup();
	model.renderModel(null);
	res.render("signup", { model: model, session: null });
};

exports.postSignup = function(req, res) {
    try {
	var model = new Signup();
	model.renderModel(req.body);
	if (model.page.theErrors.length > 0) {
		res.render("signup", { model: model, session: null });
	}
	else {
		exports.trySignup(req.body).then(function(response) {
			if (response.auth) {
				var model = new Login();
				var data = { user: { auth: false } };
				model.renderModel(data);

				var myError = new ApplicationMessage();
				myError.message = "You have successfully registered your " + config.page.applicationName + " account! A member of administration will approve your request and you will then receive a confirmation e-mail.";
				myError.isError = false;
				model.page.theErrors.push(myError);
				req.session.theErrors = model.page.theErrors;
				res.redirect("/app/login");
			}
			else {
				var model = new Signup();
				model.renderModel(req.body);

				var rawError = new Error();
				var newBody = utils.removeParams(req.body);
				var error = response.error;
				if (error == null) {
					error = new ApplicationMessage;
					error.message = "User with these credentials already exists. Please try again.";
					error.isError = true;
				}
		        var x = utils.processError(error, rawError, [newBody]);
		        utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });

				var myError = new ApplicationMessage();
				myError.message = x.message;
				myError.isError = true;
				model.page.theErrors.push(myError);
				res.render("signup", { model: model , session: null });
			}
		});
	}} catch(e) {
        var x = utils.processError(e, new Error(), null);
        utils.log('error', x.message, { "stack" : x.stack , "objects" : x.objects });
    }
};

exports.trySignup = function(data) {
	return new Promise(function(fulfill, reject) {
        var count = 0;
        var username = data.username;
        var email = data.email;
        var query = new Parse.Query("User");
        query.equalTo("username", username);
        query.find().then(function(usersA) {
            count += usersA.length;
            var queryFour = new Parse.Query("User");
            queryFour.equalTo("email", email);
            return queryFour.find();
        }).then(function(usersB) {
            count += usersB.length;
            var queryTwo = new Parse.Query("UserRegisterStructure");
            queryTwo.equalTo("username", username);
            return queryTwo.find();
        }).then(function(usersC) {
            count += usersC.length;
            var queryThree = new Parse.Query("UserRegisterStructure");
            queryThree.equalTo("email", email);
            return queryThree.find();
        }).then(function(usersD) {
            count += usersD.length;
            if (count == 0) {
                var userRegisterStructure = new Parse.Object("UserRegisterStructure");
                userRegisterStructure.set("firstName", data.firstName);
                userRegisterStructure.set("lastName", data.lastName);
                userRegisterStructure.set("email", data.email);
                userRegisterStructure.set("username", data.username);
                var newPassword = utils.encrypt(data.password);
                userRegisterStructure.set("password", newPassword);
                var key = utils.generateKey();
                userRegisterStructure.set("key", key);
                userRegisterStructure.save(null, {
                    success: function(object) {
                        fulfill({ auth: true });
                    },
                    error: function(error) {
                        fulfill({ auth: false, error: error });
                    }
                });
            } else {
                fulfill({ auth: false });
            }
        }), function(error) {
            fulfill({ auth: false, error: error });
        }
    });
};

exports.getVerify = function(req, res) {
    var username = req.session.username;
    var model = Models.Verify();
    model.renderModel(username);
    var session = Object.assign({ }, req.session);
    delete req.session.theErrors;
    res.render("verify", { model: model, session : session });
};

exports.postVerify = function(req, res) {
    exports.tryVerify(req.body).then(function (response) {
        if (response.auth) {
            var model = new Login();
            var data = { user: { auth: false } };
            model.renderModel(data);

            var myError = new ApplicationMessage();
            myError.message = "You have successfully verified your " + config.page.applicationName + " account! Please log in one more time to access your Dashboard.";
            myError.isError = false;
            model.page.theErrors.push(myError);
            req.session.theErrors = model.page.theErrors;
            res.redirect("/app/login");
        } else {
            var model = new Login();
            var data = { user: { auth: false } };
            model.renderModel(data);

            var myError = new ApplicationMessage();
            myError.message = "Unable to verify account. Please try again and ensure that your key is correct. If you have continued issues, please contact us.";
            myError.isError = true;
            model.page.theErrors.push(myError);
            req.session.theErrors = model.page.theErrors;
            res.redirect("/app/login");
        }
    });
};

exports.tryVerify = function(data) {
    return new Promise(function(fulfill, reject) {
        var username = data.username;
        var key = data.key;
        var query = new Parse.Query("User");
        query.equalTo("username", username);
        query.first({
            success: function(user) {
                var actualKey = user.get("key");
                var test = actualKey == key;
                if (test) {
                    Parse.Cloud.run("verifyUser", { username: username }, {
                        success: function(response)  {
                            fulfill({ auth: true });
                        }, error: function(error) {
                            fulfill({ auth: false, error: error });
                        }
                    });
                } else {
                    fulfill({ auth: false });
                }
            },
            error: function(error) {
                fulfill({ auth: false, error: error });
            }
        });
    });
};