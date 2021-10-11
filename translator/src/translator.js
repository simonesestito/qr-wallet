const { client } = require('./google_api');

module.exports = async function(
    stringsMap, fromLang, toLang
) {
    const results = {};
    for (const [key, string] of Object.entries(stringsMap)) {
        console.log(`Translating ${key} (${toLang})`);
        const response = await client.request({
            url: 'https://translation.googleapis.com/language/translate/v2',
            method: 'POST',
            data: {
                q: string,
                source: fromLang,
                target: toLang,
                format: 'text',
            },
        });
        results[key] = response.data.data.translations[0].translatedText;
    }
    return results;
}


