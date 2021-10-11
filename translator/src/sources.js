const { client } = require('./google_api');
const { readJson, writeJson } = require('./utils');

class FileSource {
    constructor(directory) {
        this.directory = directory;
    }

    async loadInput({ lang }) {
        return readJson(`./${this.directory}/${lang}.json`);
    }

    get cacheKey() {
        return `file:${this.directory}`;
    }

    async writeOutput({ lang }, strings) {
        return writeJson(`${this.directory}/${lang}.json`, strings);
    }

    async finalize() { }
}

module.exports = { FileSource };
