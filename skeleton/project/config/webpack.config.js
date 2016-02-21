var config = require('./assets');
var path = require('path');

module.exports = {
  entry: config.javascripts.src,
  output: {
    publicPath: '/' + config.javascripts.dest + '/',
    filename: 'bundle.js'
  },
  resolveLoader: {
    root: path.join(__dirname, 'node_modules'),
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel',
        exclude: /node_modules/
      }
    ]
  }
}