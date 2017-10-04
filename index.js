try {

    // Required for LiveQuery configuration.

    "use strict";

// Modules configuration.

    var express = require('express');
    var ParseServer = require('parse-server').ParseServer;
    var path = require('path');
    global.Parse = require('parse/node').Parse;
    var CryptoJS = require('crypto-js');
    global.config = require('./config_enc');
    var utils = require('./utils/utils');
    var routes = require('./controllers/RouteController');
    var cookieParser = require('cookie-parser');
    var session = require('express-session');
    var moment = require('moment');
    var busboy = require('busboy-body-parser');
    var bodyParser = require('body-parser');
    var S3Adapter = require('parse-server').S3Adapter;
    var Models = require('./models/models');
    var cors = require('cors');
    var config = global.config;

// Uncaught exceptions.

    process.on('uncaughtException', function (error) {
        console.log(error);
        var rawError = new Error();
        var x = utils.processError(error, rawError, null);
        utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
    });

// Variables configuration.

    var appId = utils.decrypt(config.appId);
    var masterKey = utils.decrypt(config.masterKey);
    var serverURL = utils.decrypt(config.serverURL);
    var databaseUri = utils.decrypt(config.databaseUri);
    var theClassNames = config.classNames; // Continue with re-encryption (decrypt using web-mobile utils)...then move on!
    var secret = utils.decrypt(config.secret);
    var mailgunKey = utils.decrypt(config.mailgunKey);
    var awsAccessKey = utils.decrypt(config.awsAccessKey);
    var awsSecretKey = utils.decrypt(config.awsSecretKey);
    var awsBucketName = utils.decrypt(config.awsBucketName);
    var bundle = config.bundle;
    var certPath = utils.decrypt(config.certPath);
    var devCertPath = utils.decrypt(config.devCertPath);

    var SimpleMailgunAdapter = require('./utils/SimpleMailgunAdapter');
    var simpleMailgunAdapter = new SimpleMailgunAdapter({
        apiKey: mailgunKey,
        domain: 'wildcatconnect.com',
        fromAddress: 'team@wildcatconnect.com'
    });

// Parse Server configuration.

    var api = new ParseServer({
        databaseURI: databaseUri,
        cloud: __dirname + '/cloud/main.js',
        appId: appId,
        masterKey: masterKey,
        serverURL: serverURL,
        publicServerURL: serverURL,
        appName: config.page.applicationName,
        emailAdapter: simpleMailgunAdapter,
        filesAdapter: new S3Adapter(
            awsAccessKey,
            awsSecretKey,
            awsBucketName,
            {directAccess: true}
        ),
        push: {
            ios: [
                {
                    pfx: certPath,
                    bundleId: bundle,
                    production: true
                },
                {
                    pfx: devCertPath,
                    bundleId: bundle,
                    production: false
                }
            ]
        }
    });

    Parse.initialize(appId, masterKey);
    Parse.serverURL = serverURL;

// Express app configuration.

    var app = express();

    app.use(busboy());
    app.use(bodyParser.json());

// Session configuration.

    app.use(cookieParser());
    app.use(session({secret: secret, resave: true, saveUninitialized: true}));

// Serve static assets from the /public folder

    app.use(express.static('public'));

// Handle local variables...

    app.use(cors());

    app.use(function (req, res, next) {
        res.locals.moment = moment;
        next();
    });

// Serve the Parse API on the /Parse URL prefix

    var mountPath = config.parseMount;
    app.use(mountPath, api);

// Configure routing

    app.use(bodyParser.urlencoded({extended: true}));

    app.use(function (req, res, next) {
        res.header("Access-Control-Allow-Origin", "*");
        res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        next();
    });

    app.use('/', routes);

    app.use(function (req, res, next) {
        utils.log('error', "Page not found.", {url: req.url});
        var model = utils.initializeHomeUserModel(req.session.user);
        model.page.title = "Not Found";
        model.error = {
            url: req.url,
            code: 404
        };
        res.status(404).render("error", {model: model});
    });

    app.set('views', __dirname + '/views/pages');
    app.set('view engine', 'ejs');

// HTTP configuration.

    var port = process.env.PORT || 5000;
    var httpServer = require('http').createServer(app);
    httpServer.listen(port, function () {
        console.log('Began client on port ' + port + '.');
    });

} catch(e) {
    console.log(e.stack);
    var rawError = new Error();
    var x = utils.processError(e, rawError, null);
    utils.log('error', x.message, {"stack": x.stack, "objects": x.objects});
}