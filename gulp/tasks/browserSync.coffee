# browser-sync task
# -----------------

gulp        = require "gulp"
browserSync = require "browser-sync"
argv        = require("yargs").argv

gulp.task "browserSync", ["build"], ->
    browserSync.init ["build/**"],
        open: argv.browser
        server:
            baseDir: "build"
