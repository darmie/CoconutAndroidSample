var chokidar = require('chokidar');

var watcher = chokidar.watch('./src', { ignored: /[\/\\]\./, persistent: true });
const { spawn } = require('child_process');

var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);

watcher
    .on('add', function (path) { console.log('File', path, 'has been added'); })
    .on('addDir', function (path) { console.log('Directory', path, 'has been added'); })
    .on('change', function (path) {
        console.info('File', path, 'has been changed');
        console.info("[COMPILER]: Rebuilding the code...");
        const build = spawn('npm', ['run', 'haxe', 'project.hxml']);

        build.on('exit', function (code, signal) {
            console.info('build process exited with ' +
                `code ${code} and signal ${signal}`);
            
            if (code == 0) {
                console.info("[COMPILER]: Done!");
                const dexer = spawn('');
                console.info("[DEXER]: Transforming Build Output...");
                dexer.on('exit', (_code, _signal) => {
                    console.info('dexer process exited with ' +
                        `code ${_code} and signal ${_signal}`);
                    if (_code == 0) {
                        // emit app:reload
                        console.info("Reaload!");
                        io.emit("app:reload", "");
                    }
                })
                dexer.stdout.on('data', (data) => {
                    console.log(`Dexer output:\n${data}`);
                });
            }
        });

        build.stdout.on('data', (data) => {
            console.log(`Haxe build:\n${data}`);
        });
    })
    .on('unlink', function (path) { console.log('File', path, 'has been removed'); })
    .on('unlinkDir', function (path) { console.log('Directory', path, 'has been removed'); })
    .on('error', function (error) { console.error('Error happened', error); })



http.listen(3333, () => {
    console.log('listening on *:3333');
});