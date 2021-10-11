const { client } = require('./google_api');

module.exports = async function(
    stringsMap, source, target, format
) {
    const results = {};
    for (const [key, string] of Object.entries(stringsMap)) {
        console.log(`Translating ${key} (${target})`);
        const response = await client.request({
            url: 'https://translation.googleapis.com/language/translate/v2',
            method: 'POST',
            data: { q: string, source, target, format },
        });
        results[key] = response.data.data.translations[0].translatedText;
    }
    return results;
}


