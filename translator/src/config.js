const { FileSource, PlayListingSource } = require('./sources');
const translate = require('./translator');
const fs = require('fs').promises; //require('fs/promises');

module.exports = readFromGlobals('../lib/lang/locales.dart', 'en', 'it')
    .then(languages => deepFreeze({
        sources: [
            {
                source: new FileSource('../assets/languages'),
                nonTranslatable: [
                    'app_title',
                    'app_title_extended',
                    'author_back',
                    'author_front',
                ],
            },
            {
                source: new PlayListingSource(),
                nonTranslatable: [ 'title' ],
            },
        ],
        cacheFile: './translations_cache.json',
        defaultLanguage: { lang: 'en', fullLang: 'en-US' },
        languages: languages,
        translator: translate,
    }
));

function deepFreeze(obj) {
    Object.freeze(obj);
    if (typeof obj === 'object' && obj.constructor == Object) {
        Object.getOwnPropertyNames(obj)
            .map(k => obj[k])
            .forEach(deepFreeze);
    }
    return obj;
}

async function readFromGlobals(localesFile, ...ignoredLanguages) {
    const file = (await fs.readFile(localesFile)).toString();
    const regex = /const Locale\('([a-z]*)',\s'([A-Z]*)'\)/g;
    const matches = [...file.matchAll(regex)];
    return matches
        .map(match => ({
            lang: match[1],
            fullLang: match[1] + '-' + match[2],
        }))
        .filter(({ lang }) => ignoredLanguages.indexOf(lang) == -1);
}

