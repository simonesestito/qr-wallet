const configPromise = require('./config');
const { readJson, writeJson } = require('./utils');

async function main() {
    const config = await configPromise;
    const cache = await readJson(config.cacheFile);
    for (const sourceConf of config.sources) {
        const { source } = sourceConf;
        const sourceKey = source.cacheKey;

        const input = await source.loadInput(
            config.defaultLanguage
        );
        Object.freeze(input);
        const cached = cache[sourceKey] ?? {};
        const old = cached['old'] ?? {};
        
        for (const lang of config.languages) {
            const toTranslate = new Set();
            const output = {};

            // Edited strings
            Object.entries(input)
                .filter(([k, v]) => v != old[k])
                .forEach(([k, v]) => toTranslate.add(k));

            // New strings for this lang
            const langCache = cached[lang] ?? [];
            Object.keys(input)
                .filter(k => langCache.indexOf(k) == -1)
                .forEach(k => toTranslate.add(k));

            // Non translatable
            sourceConf.nonTranslatable
                .forEach(key => {
                    output[key] = input[key];
                    toTranslate.delete(key);
                });

            const stringsMap = Object.fromEntries(
                Object.entries(input)
                    .filter(([k,v]) => toTranslate.has(k))
            );

            // Translate input in this language
            const diff = await config.translator(
                stringsMap,
                config.defaultLanguage,
                lang
            );
            Object.entries(diff).forEach(([k,v]) => output[k] = v);

            Object.entries(
                Object.keys(output).length ==
                    Object.keys(input).length
                ? {}
                : await source.loadInput(lang)
            ).filter(([k,v]) => Object.keys(output).indexOf(k) == -1)
            .forEach(([k,v]) => output[k] = v);

            await source.writeOutput(lang, output);
            cached[lang] = Object.keys(output);
        }

        await source.finalize();

        // Update defaultLanguage cache
        cached['old'] = input;
        cache[sourceKey] = cached;
    }

    // Write updated cache
    await writeJson(
        config.cacheFile,
        cache
    );
}

main().catch(console.log);
