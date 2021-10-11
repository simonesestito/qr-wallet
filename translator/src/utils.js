const fs = require('fs/promises');

async function readJson(file) {
    return fs.readFile(file)
        .then(JSON.parse)
        .catch(() => ({}));
}

async function writeJson(file, object) {
    return fs.writeFile(
        file,
        JSON.stringify(object, null, 2)
    );
}

module.exports = { readJson, writeJson };