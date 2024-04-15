const crypto = require('crypto');
const fs = require('fs');

function generateSecretKey() {
    return crypto.randomBytes(32).toString('hex');
}

function loadSecretKey() {
    try {
        const data = fs.readFileSync('./secret.key', 'utf8');
        if (data) {
            return data;
        } else {
            throw new Error('Empty key file');
        }
    } catch (err) {
        const secretKey = generateSecretKey();
        fs.writeFileSync('secret.key', secretKey);
        return secretKey;
    }
}

module.exports = {
    generateSecretKey,
    loadSecretKey
};