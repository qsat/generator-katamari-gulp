_ = require 'underscore'
gulp = require 'gulp'
jade = require 'gulp-jade'
stylus = require 'gulp-stylus'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
changed = require 'gulp-changed'
imagemin = require 'gulp-imagemin'
transform = require 'vinyl-transform'
browserify = require 'browserify'
browserSync = require 'browser-sync'
spritesmith = require 'gulp.spritesmith'
plumber = require 'gulp-plumber'
watchify = require 'watchify'
pngcrush = require 'imagemin-pngcrush'
pngquant = require 'imagemin-pngquant'

expand = (ext)-> rename (path) -> _.tap path, (p) -> p.extname = ".#{ext}"
notify = (filename) -> console.log(filename)

DEST = "./dist"
SRC = "./src"
CHANGED = "./__modified"

# ファイルタイプごとに無視するファイルなどを設定
paths =
  js: ["#{SRC}/**/*.coffee", "!#{SRC}/**/_**/*.coffee", "!#{SRC}/**/_*.coffee"]
  css: ["#{SRC}/**/*.styl", "!#{SRC}/**/sprite*.styl", "!#{SRC}/**/_**/*.styl", "!#{SRC}/**/_*.styl"]
  img: ["#{SRC}/**/*.{png, jpg, gif}", "!#{SRC}/**/sprite/**/*.png"]
  html: ["#{SRC}/**/*.jade", "!#{SRC}/**/_**/*.jade", "!#{SRC}/**/_*.jade"]
  reload: ["#{DEST}/**/*", "!#{DEST}/**/*.css"]
  sprite: "#{SRC}/**/sprite/**/*.png"

gulp.task 'browserify', ->

  bundler = (options) ->
    transform (filename) ->
      b = browserify _.extend options, {}#watchify.args

      # watch
      #b = watchify b
      b.add filename

      # transform
      b.transform 'coffeeify'
      b.transform 'jadeify'
      b.transform 'stylify'
      b.transform 'debowerify'

      # events
      b.on 'bundle', notify.bind null, 'BUNDLE ' + filename
      b.on 'error', -> console.log "error"
      b.on 'log', -> console.log arguments
      b.on 'update', ->
        console.log "asdasd"
        bundle()

      b.bundle()

  bundle = ->
    gulp.src paths.js
      .pipe plumber()
      .pipe bundler extensions: ['.coffee']
      .pipe expand "js"
      #.pipe uglify()
      .pipe gulp.dest DEST
      .pipe gulp.dest CHANGED

  bundle()

# FW for Stylus
nib = require 'nib'

gulp.task "stylus", ["sprite"], ->
  gulp.src paths.css
    .pipe plumber()
    .pipe changed DEST
    .pipe stylus use: nib(), errors: true
    .pipe expand "css"
    .pipe gulp.dest DEST
    .pipe gulp.dest CHANGED
    .pipe browserSync.reload stream:true

gulp.task "jade", ->
  gulp.src paths.html
    .pipe plumber()
    .pipe jade pretty: true
    .pipe expand "html"
    .pipe gulp.dest DEST
    .pipe gulp.dest CHANGED

gulp.task "imagemin", ->
  gulp.src paths.img
    .pipe imagemin
      use: [pngcrush(), pngquant()]
    .pipe gulp.dest DEST

gulp.task "browser-sync", ->
  browserSync.init null,
    reloadDelay:2000,
    #startPath: 'a.html'
    server: baseDir: DEST

# http://blog.e-riverstyle.com/2014/02/gulpspritesmithcss-spritegulp.html
gulp.task "sprite", ->
  a = gulp.src paths.sprite
    .pipe plumber()
    .pipe spritesmith
      imgName: 'images/sprite.png'
      cssName: 'images/sprite.styl'
      imgPath: 'images/sprite.png'
      algorithm: 'binary-tree'
      cssFormat: 'stylus'
      padding: 4

  a.img.pipe gulp.dest SRC
  a.img.pipe gulp.dest DEST
  a.css.pipe gulp.dest SRC

gulp.task 'watch', ->
    gulp.watch [paths.js[0], "#{SRC}/**/_*/*"], ['browserify']
    gulp.watch paths.css  , ['stylus']
    gulp.watch paths.html , ['jade']
    gulp.watch paths.reload, -> browserSync.reload once: true

gulp.task "default", ['jade', 'stylus', 'browserify', 'browser-sync', 'watch'] 
gulp.task "build", ['imagemin', 'stylus', 'browserify', 'jade']
