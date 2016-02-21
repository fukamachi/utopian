module.exports = {
   javascripts: {
     src: './assets/javascripts/app.js',
     dest: 'public/assets'
   },
   stylesheets: {
     less: {
       src: './assets/stylesheets/app.less',
       path: ['assets/stylesheets/']
     },
     dest: 'public/assets'
   },
   watch: {
     javascripts: 'assets/javascripts/**/*.js',
     stylesheets: {
       less: 'assets/stylesheets/**/*.less'
     }
   }
}