gulp         = require "gulp"
compass      = require "gulp-compass"
notify       = require "gulp-notify"
handleErrors = require "../util/handleErrors"

gulp.task "compass", ->
    gulp.src "./src/sass/*.scss"
    .pipe compass
        # config_file: "compass.rb"
        css: "build"
        sass: "src/sass"
        image: "build/images"
        font: "build/fonts"
    .on "error", handleErrors

# Replaced compass.rb with the options in here.
# Things might not work. Original compass.rb:

###
preferred_syntax = :sass
http_path = "/"
css_dir = "build"
sass_dir = "src/sass"
images_dir = "build/images"
fonts_dir = "build/fonts"
relative_assets = true
line_comments = true
###
