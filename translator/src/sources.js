const { client } = require('./google_api');
const { readJson, writeJson } = require('./utils');

class FileSource {
    constructor(directory) {
        this.directory = directory;
    }

    async loadInput(language) {
        return readJson(`./${this.directory}/${language}.json`);
    }

    get cacheKey() {
        return `file:${this.directory}`;
    }

    async writeOutput(language, strings) {
        return writeJson(
            `${this.directory}/${language}.json`,
            strings,
        );
    }

    async finalize() { }
}

module.exports = { FileSource };
