module.exports = (grunt) ->
  grunt.config.init 
    pkg: grunt.file.readJSON("package.json")
    meta:
      version: "<%= pkg.version %>"
      banner: "/* <%= pkg.name %>  - v<%= pkg.version %>"+
        "* generated: <%= grunt.template.today(\"yyyy-mm-dd - HH:mm:ss.sss\") %>*/\n\n\n"
    js: 
      files:
        app: ["lib/lightrock.jquery.coffee"]
    coffee:
      options:
        bare: true
      compile:
        files:
          "src/lightrock.jquery.js": "<%= js.files.app %>"
    watch:
      scripts:
        files:"<%= js.files.app %>"
        tasks: "default"
    uglify:
      dist:
        src: "src/lightrock.jquery.js"
        dest: "src/lightrock.jquery.min.js"        
      
  grunt.loadNpmTasks "grunt-contrib"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.registerTask "default", ["coffee", "uglify"]