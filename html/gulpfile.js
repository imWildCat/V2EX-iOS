var gulp = require('gulp');
var watch = require('gulp-watch');
var uglify = require('gulp-uglify');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var rename = require("gulp-rename");
var browserify = require('browserify');
var babelify = require('babelify');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');

var paths = {
  topic_index_js: './src/topic_index.jsx',
  node_list_index_js: './src/node_list_index.jsx',
  components: './src/components/**/*.jsx',
  scss: './src/scss/*.scss',
  html: ['./src/html/topic.html', './src/html/topic_demo.html', './src/html/node_list.html',
    './src/html/node_list_demo.html'],
  dist_html: ['./src/html/topic.html', './src/html/node_list.html']
};


// react
gulp.task('react', function () {

  browserify({
    entries: paths.topic_index_js,
    extensions: ['.jsx'],
    debug: true
  })
    .transform(babelify)
    .bundle()
    .pipe(source('topic_bundle.js'))
    .pipe(buffer())
    .pipe(gulp.dest('./build'));

  browserify({
    entries: paths.node_list_index_js,
    extensions: ['.jsx'],
    debug: true
  })
    .transform(babelify)
    .bundle()
    .pipe(source('node_list_bundle.js'))
    .pipe(buffer())
    .pipe(gulp.dest('./build'));
});

gulp.task('scss', function () {
  gulp.src(paths.scss)
    .pipe(sass())
    .pipe(concat('style.css'))
    .pipe(gulp.dest('./build'));
});

gulp.task('html', function () {
  gulp.src(paths.html)
    .pipe(gulp.dest('./build'));
  gulp.src('./src/img/*.png').pipe(gulp.dest('./build'));
});

gulp.task('dist', function () {
  // js
  browserify({
    entries: paths.topic_index_js,
    extensions: ['.jsx'],
    debug: true
  })
    .transform(babelify)
    .bundle()
    .pipe(source('topic_bundle.js'))
    .pipe(buffer())
    .pipe(uglify())
    .pipe(gulp.dest('../V2EX/www/js'));

  browserify({
    entries: paths.node_list_index_js,
    extensions: ['.jsx'],
    debug: true
  })
    .transform(babelify)
    .bundle()
    .pipe(source('node_list_bundle.js'))
    .pipe(buffer())
    .pipe(uglify())
    .pipe(gulp.dest('../V2EX/www/js'));

  // scss
  gulp.src(paths.scss)
    .pipe(sass())
    .pipe(concat('style.css'))
    .pipe(gulp.dest('../V2EX/www/css'));
  // html
  gulp.src(paths.dist_html)
    .pipe(gulp.dest('../V2EX/www/html'));
  // img
  gulp.src('./src/img/*.png').pipe(gulp.dest('../V2EX/www/img'));
});

gulp.task('watch', function () {
  gulp.watch(paths.index_js, ['react', 'dist']);
  gulp.watch(paths.components, ['react', 'dist']);
  gulp.watch([paths.scss, './src/scss/**/*.scss'], ['scss', 'dist']);
  gulp.watch(paths.html, ['html', 'dist']);
});

gulp.task('default', ['watch', 'react', 'scss', 'html', 'dist']);