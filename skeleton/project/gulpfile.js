var gulp = require('gulp'),
    less = require('gulp-less'),
    watch = require('gulp-watch'),
    prefix = require('gulp-autoprefixer'),
    plumber = require('gulp-plumber'),
    webpack = require('webpack-stream'),
    config = require('./config/assets'),
    webpackConfig = require('./config/webpack.config'),
    source = require('vinyl-source-stream');

// Compile LESS to CSS
gulp.task('build-less', function() {
  return gulp.src(config.stylesheets.less.src)
    .pipe(plumber())
    .pipe(less({ paths: config.stylesheets.less.path }))
    .pipe(gulp.dest(config.stylesheets.dest));
});

gulp.task('build-js', function() {
  gulp.src(webpackConfig.entry)
    .pipe(plumber())
    .pipe(webpack(webpackConfig))
    .pipe(gulp.dest(config.javascripts.dest));
});

// Watch all LESS files, then run build-less
gulp.task('watch', ['build-less', 'build-js'], function() {
  gulp.watch(config.watch.javascripts, ['build-js']);
  gulp.watch(config.watch.stylesheets.less, ['build-less']);
});

gulp.task('default', ['build-less', 'build-js']);
