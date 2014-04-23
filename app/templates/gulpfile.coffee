_ = require 'underscore'
gulp = require 'gulp'
jade = require 'gulp-jade'
sftp = require 'gulp-sftp'
stylus = require 'gulp-stylus'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
changed = require 'gulp-changed'
imagemin = require 'gulp-imagemin'
browserify = require 'gulp-browserify'
browserSync = require 'browser-sync'

expand = (ext)-> rename (path) -> _.tap path, (p) -> p.extname = ".#{ext}"

DEST = "./htdocs"
SRC = "./src"

paths =
  js: "#{SRC}/**/app.coffee"
  css: "#{SRC}/**/*.styl"
  img: "#{SRC}/**/*.{png, jpg, gif}"
  html: "#{SRC}/**/*.jade"

gulp.task 'browserify', ->
  gulp.src paths.js, read: false
    .pipe changed DEST
    .pipe browserify
        debug: true,
        transform: ['coffeeify'],
        extensions: ['.coffee'], 
    .pipe expand "js"
    #.pipe uglify()
    .pipe gulp.dest DEST
    .pipe browserSync.reload stream:true, once: true

# FW for Stylus
nib = require 'nib'

gulp.task "stylus", ->
  gulp.src paths.css
    .pipe changed DEST
    .pipe stylus use: nib()
    .pipe expand "css"
    .pipe gulp.dest DEST
    .pipe browserSync.reload stream:true

gulp.task "jade", ->
  gulp.src paths.html
    .pipe changed DEST
    .pipe jade pretty: true
    .pipe expand "html"
    .pipe gulp.dest DEST

gulp.task "imagemin", ->
  gulp.src paths.img
    .pipe changed DEST
    .pipe imagemin pngquant: true
    .pipe gulp.dest DEST

gulp.task "browser-sync", ->
  browserSync.init null,
    reloadDelay:2000,
    #startPath: 'a.html'
    server: baseDir: DEST

gulp.task "sftp", ->
  gulp.src DEST
    .pipe changed DEST
    .pipe sftp
      host: 'example.com'
      user: 'myname'
      #pass: '1234'
      key:  require('fs').readFileSync('~/.ssh/privatekey.pem')

# http://blog.e-riverstyle.com/2014/02/gulpspritesmithcss-spritegulp.html
gulp.task "spritesmith"

gulp.task 'watch', ->
    gulp.watch paths.js  , ['browserify']
    gulp.watch paths.css , ['stylus']
    gulp.watch paths.html, ['jade']
    gulp.watch "#{DEST}/**/*.html", -> browserSync.reload()

gulp.task "default", ['browser-sync', 'watch'] 
