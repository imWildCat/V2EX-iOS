var gulp = require('gulp');
var watch = require('gulp-watch');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var inlinesource = require('gulp-inline-source');
var rename = require("gulp-rename");
var browserify = require('browserify');
var babelify = require('babelify');
var source = require('vinyl-source-stream');

var runSequence = require('gulp-run-sequence');
var clean = require('gulp-clean');

var paths = {
    script: './src/js/*.js',
    jQuery: './bower_components/jquery/dist/jquery.js',
    scss: './src/scss/*.scss',
    img: './src/img/*.png',
    html: './src/html/*.html',

    index_js: './src/index.jsx',
    components: './src/components/*.jsx'
};


gulp.task('scss', function () {
    gulp.src(paths.scss)
        .pipe(sass())
        .pipe(concat('style.css'))
        .pipe(gulp.dest('./build/css'));
});

gulp.task('script', function () {
    gulp.src([paths.jQuery, paths.script])
        .pipe(concat('script.js'))
        .pipe(gulp.dest('./build/js'));
});

gulp.task('demo-images', function () {
    gulp.src('./src/img/*.png').pipe(gulp.dest('./build/img'));
});

gulp.task('demo-html', function () {
    gulp.src('./src/html/*.html')
        .pipe(inlinesource())
        .pipe(gulp.dest('./build'));
});

gulp.task('dist-sources', function () {
    // html
    gulp.src('./src/html/production_topic.html')
        .pipe(inlinesource())
        .pipe(rename('topic_tpl.html'))
        .pipe(gulp.dest('../V2EX/www'));
    // img
    gulp.src('./src/img/*.png').pipe(gulp.dest('../V2EX/www/img'));
});

gulp.task('build-clean', function () {
    //return gulp.src('build').pipe(clean());
});

gulp.task('build-demo', function () {
    runSequence('build-clean', 'script', 'scss', 'demo-html', 'demo-images', 'dist-sources');
});

gulp.task('build', function () {
    runSequence('build-demo');
    // todo: dist
});


gulp.task('watch', function () {
    gulp.watch(paths.script, ['build']);
    gulp.watch(paths.scss, ['build']);
    gulp.watch(paths.html, ['build']);
});


// node list
gulp.task('react', function () {
    browserify({
        entries: './src/index.jsx',
        extensions: ['.jsx'],
        debug: true
    })
        .transform(babelify)
        .bundle()
        .pipe(source('bundle.js'))
        .pipe(gulp.dest('./build'));
});

gulp.task('html', function () {
    gulp.src('./src/html/*.html')
        .pipe(gulp.dest('./build'));
});

gulp.task('node_list_watch', function () {
    gulp.watch(paths.index_js, ['react']);
    gulp.watch(paths.components, ['react']);

    gulp.watch(paths.html, ['html']);
});


gulp.task('default', ['build', 'watch', 'react', 'html']);