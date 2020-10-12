var chokidar = require('chokidar');

var watcher = chokidar.watch('./src', { ignored: /[\/\\]\./, persistent: true });
const { spawn, fork } = require('child_process');

var app = require('express')();
var http = require('http').createServer(app);
var io = require('socket.io')(http);

const path = require('path');
const fs = require("fs");
const { trace } = require('console');


const ANDROID_SDK_ROOT = process.env.ANDROID_SDK_ROOT;
const ANDROID_TOOLS_PATH = path.join(ANDROID_SDK_ROOT, "build-tools");

function compile() {
    const compile_server = spawn('node_modules/.bin/haxe', ['-v', '--wait', '6666']);

    process.on('SIGINT', function () {
        console.log("\nCaught interrupt signal");

        compile_server.kill("SIGINT");
        spawn("kill", ["-9", compile_server.pid]);
        process.exit(0);
    });

    compile_server.stdout.on('data', (data) => {
        console.log(`Haxe Compiler Server Output:\n${data}`);
    });

    compile_server.stderr.on('data', (data) => {
        console.log(`Haxe Compiler Server Output:\n${data}`);
    });

    return compile_server.pid;
}




const COMPILER_ID = compile();

io.on('connection', (socket) => {
    console.log('Device connected');
    startWatch();
});

function startWatch() {
    var ANDROID_BUILD_TOOL = "";
    if (fs.existsSync(ANDROID_TOOLS_PATH)) {
        console.log(ANDROID_TOOLS_PATH);
        try {
            const files = fs.readdirSync(ANDROID_TOOLS_PATH);
            delete files[files.indexOf(".DS_Store")];

            files.sort((a, b) => {
                var num1 = a.split("-")[1];
                var num2 = b.split("-")[1];
                if (num1 == null)
                    return 0;
                if (num2 == null)
                    return 0;
                if (num1 < num2)
                    return 1;
                else if (num1 > num2)
                    return -1;
                else
                    return 0;
            });

            ANDROID_BUILD_TOOL = files[0];

            const DEXER = path.join(ANDROID_TOOLS_PATH, ANDROID_BUILD_TOOL, 'dx');

            const runner = (args) => {
                let  build = spawn('node_modules/.bin/haxe', args);
                io.emit("app:compiling", "1/5");
                build.on('exit', function (code, signal) {
                    console.info('build process exited with ' +
                        `code ${code} and signal ${signal}`);
                    io.emit("app:compiling", "2/5");
                    if (code == 0) {
                        console.info("[COMPILER]: Done!");
                        if (!fs.existsSync(path.join("build"))) {
                            fs.mkdirSync(path.join("build"));
                        } else {
                            rmdirAsync(path.join("build"), (err, _) => {
                                fs.mkdirSync(path.join("build"));
                            });
                        }
                        io.emit("app:compiling", "3/5");
                        const dexer = spawn(DEXER, ['--dex', '--output', 'build/coco.dex', 'coco.android/app/bin/libcoco.jar']);
                        console.info("[DEXER]: Transforming Build Output...");
                        io.emit("app:compiling", "4/5");
                        dexer.on('exit', (_code, _signal) => {
                            console.info('dexer process exited with ' +
                                `code ${_code} and signal ${_signal}`);
                            io.emit("app:compiling", "5/5");
                            if (_code == 0) {
                                // emit app:reload
                                console.info("[Reload!]");
                                var buf = fs.readFileSync(path.join("build", "coco.dex"));
                                var hex = buf.toString("hex");
                                // console.log(hex);
                                io.emit("app:reload", hex);
                            }
                        })
                        dexer.stdout.on('data', (data) => {
                            console.log(`Dexer output:\n${data}`);
                        });
                        dexer.stderr.on('data', (data) => {
                            console.log(`Dexer Error:\n${data}`);
                        });

                        process.on('SIGINT', function () {
                            dexer.kill("SIGINT");
                        });
                    } else if (code == 1) {
                        build.kill("SIGINT");
                        spawn("kill", ["-9", COMPILER_ID]);
                        
                        build = runner(['project.hxml']);
                    }
                });

                build.stdout.on('data', (data) => {
                    console.log(`Haxe build:\n${data}`);
                });

                build.stderr.on('data', (data) => {
                    console.log(`Haxe error:\n${data}`);
                });

                process.on('SIGINT', function () {
                    build.kill("SIGINT");
                    spawn("kill", ["-9", COMPILER_ID]);
                });
            
            }

            runner(['--cwd', './', '--connect', '6000', 'project.hxml']);
            watcher.on('change', function (_path) {
                    console.info('File', _path, 'has changed');
                    console.info("[COMPILER]: Rebuilding the code...");
                    runner(['--cwd', './', '--connect', '6000', 'project.hxml']);
            });
        } catch (e) {
            trace(e);
        }
    }
}

var rmdirAsync = function (path, callback) {
    fs.readdir(path, function (err, files) {
        if (err) {
            // Pass the error on to callback
            callback(err, []);
            return;
        }
        var wait = files.length,
            count = 0,
            folderDone = function (err) {
                count++;
                // If we cleaned out all the files, continue
                if (count >= wait || err) {
                    fs.rmdir(path, callback);
                }
            };
        // Empty directory to bail early
        if (!wait) {
            folderDone();
            return;
        }

        // Remove one or more trailing slash to keep from doubling up
        path = path.replace(/\/+$/, "");
        files.forEach(function (file) {
            var curPath = path + "/" + file;
            fs.lstat(curPath, function (err, stats) {
                if (err) {
                    callback(err, []);
                    return;
                }
                if (stats.isDirectory()) {
                    rmdirAsync(curPath, folderDone);
                } else {
                    fs.unlink(curPath, folderDone);
                }
            });
        });
    });
};


http.listen(3333, () => {
    console.log('listening on *:3333');
});