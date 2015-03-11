'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var chalk = require('chalk');


var KatamariGulpGenerator = yeoman.generators.Base.extend({
  init: function () {
    this.pkg = require('../package.json');

    this.on('end', function () {
      if (!this.options['skip-install']) {
        this.installDependencies();
      }
    });
  },

  askFor: function () {
    var done = this.async();

    // have Yeoman greet the user
    this.log(this.yeoman);

    // replace it with a short and sweet description of your generator
    this.log(chalk.magenta('You\'re using the fantastic KatamariGulp generator.'));

    var prompts = [{
      name: 'projectName',
      message: "Please enter your project's name.",
    }];

    this.prompt(prompts, function (props) {
      this.projectName = props.projectName;

      done();
    }.bind(this));
  },

  app: function () {
    this.mkdir('dist');
    this.mkdir('src');
    this.mkdir('src/images');

    this.template('_package.json', 'package.json');
    this.template('gulpfile.coffee', 'gulpfile.coffee');
    this.template('src/index.jade', 'src/index.jade');
    this.copy('src/index.coffee', 'src/index.coffee');
    this.copy('src/images/sprite.styl', 'src/images/sprite.styl');
    this.copy('src/images/sprite.png', 'src/images/sprite.png');
    this.copy('src/index.styl', 'src/index.styl');
    this.copy('_gitignore', '.gitignore');
  },

  projectfiles: function () {
    this.copy('editorconfig', '.editorconfig');
    this.copy('jshintrc', '.jshintrc');
  }
});

module.exports = KatamariGulpGenerator;
