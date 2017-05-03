// Copyright © 2016 RTE Réseau de transport d’électricité

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    browserify: {
      options: {
        browserifyOptions : {
          debug: true
        }
      },
      build: {
        files: {
          "../inst/leaflet.minicharts.min.js": ["index.js"]
        }
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= pkg.version %> <%= grunt.template.today("yyyy-mm-dd") %>\n' +
                'Copyright © 2016 RTE Réseau de transport d’électricité */\n'
      },
      build: {
        src: '../inst/leaflet.minicharts.min.js',
        dest: '../inst/leaflet.minicharts.min.js'
      },
    },
    watch: {
      build: {
        files: ["*.js"],
        tasks: ['browserify', 'uglify']
      }
    }
  });

  // Load plugins
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  // Default task(s).
  grunt.registerTask('build', ['browserify', 'uglify']);
  grunt.registerTask('default', ["build"]);

};
