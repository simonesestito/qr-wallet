const {JWT} = require('google-auth-library');
const keys = require('../service_account.json');

const SCOPES = [
    'https://www.googleapis.com/auth/androidpublisher',
    'https://www.googleapis.com/auth/cloud-translation',
];

const client = new JWT({
    email: keys.client_email,
    key: keys.private_key,
    scopes: SCOPES,
});

module.exports = { client };
