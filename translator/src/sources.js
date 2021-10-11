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

    get format() {
        return 'text';
    }

    async writeOutput({ lang }, strings) {
        return writeJson(`${this.directory}/${lang}.json`, strings);
    }

    async finalize() { }
}

const PLAY_BASE_URL = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.exos.qrwallet/edits';

class PlayListingSource {
    async loadInput({ fullLang }) {
        await this.initEdit();
        const response = await client.request({
            url: `${PLAY_BASE_URL}/${this.editId}/listings/${fullLang}`,
            method: 'GET',
        });
        return {
            title: response.data.title,
            fullDescription: response.data.fullDescription,
            shortDescription: response.data.shortDescription,
        };
    }

    get cacheKey() {
        return 'play_listing';
    }

    get format() {
        return 'text';
    }

    async writeOutput({ lang, fullLang }, strings) {
        await this.initEdit();

        strings.shortDescription = strings.shortDescription.substr(0, 80);

        const tryLanguage = (langCode) => {
            return client.request({
                url: `${PLAY_BASE_URL}/${this.editId}/listings/${langCode}`,
                method: 'PUT',
                data: {
                    ...strings,
                    language: langCode,
                    video: "",
                },
            });
        }

        await tryLanguage(fullLang)
            .catch(() => tryLanguage(lang))
            .catch(err => console.log(err.errors[0].message));
    }

    async finalize() {
        await this.initEdit();
        await client.request({
            url: `${PLAY_BASE_URL}/${this.editId}:commit?changesNotSentForReview=false`,
            method: 'POST',
        });
    }

    async initEdit() {
        if (this.editId)
            return;

        const response = await client.request({
            url: PLAY_BASE_URL,
            method: 'POST'
        });
        this.editId = response.data.id;
    }
}

module.exports = { FileSource, PlayListingSource };
