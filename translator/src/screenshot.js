const fs = require('fs').promises;
const { exec } = require('child_process');
const dgram = require('dgram');
const configPromise = require('./config');

const FAB_X_Y = [ 950, 2220 ];
const DELETE_X_Y = [ 363, 2070 ];
const RENAME_X_Y = [ 780, 2070 ];

function runCommand(command) {
    return new Promise((res, rej) => {
        exec(command, { encoding: 'buffer', maxBuffer: 1024*1024*50 }, (err, stdout, stderr) => {
            if (err)
                rej(err);
            else
                res(stdout);
        });
    });
}

function tap([ x, y ]) {
    return runCommand(`adb shell input tap ${x} ${y}`).then(wait);
}

function back() {
    return runCommand('adb shell input keyevent 4').then(wait);
}

function wait(millis = 500) {
    return new Promise(res => setTimeout(res, millis));
}

async function screenshot(filename) {
    const bytes = await runCommand('adb exec-out screencap -p');
    await fs.writeFile(filename, bytes);
}

function demoMode(enable) {
    return runCommand('adb shell am broadcast -a com.android.systemui.demo -e command ' + (enable ? 'enter' : 'exit')).then(wait);
}

async function send(locale, theme) {
    console.log(locale, theme);
    const txt = `qrwallet ${locale} ${theme}`;
    const ip = await runCommand('adb shell ip addr show wlan0').then(output => {
        const regex = /[1-9][0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,3}\.[1-9][0-9]{0,2}/;
        return [...output.toString().matchAll(regex)][0][0];
    });
    dgram.createSocket('udp4').send(txt, 0, txt.length, 12345, ip);
    return wait(1500);
}

async function mkdir(dir) {
    try {
        await fs.access(dir);
    } catch (err) {
        await fs.mkdir(dir);
    }
}

(async () => {
    const config = await configPromise;
    await demoMode(true);

    await mkdir('screenshots');

    for (const { lang } of config.languages.slice(26)) {
        await mkdir(`screenshots/${lang}`);
        for (const theme of [ 'light', 'dark' ]) {
            await mkdir(`screenshots/${lang}/${theme}`);
            await send(lang, theme);

            await screenshot(`screenshots/${lang}/${theme}/home.png`);

            await tap(FAB_X_Y);
            await screenshot(`screenshots/${lang}/${theme}/add.png`);
            await back();

            await tap(DELETE_X_Y);
            await screenshot(`screenshots/${lang}/${theme}/delete.png`);
            await back();

            await tap(RENAME_X_Y);
            await screenshot(`screenshots/${lang}/${theme}/rename.png`);
            await back();
        }
    }

    await demoMode(false);
})().catch(console.error);