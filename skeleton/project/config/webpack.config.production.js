var path = require('path');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: './assets/javascripts/app.js',
  output: {
    path: path.join(__dirname, '..', 'public'),
    publicPath: '../',
    filename: 'assets/bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          use: ['css-loader', 'sass-loader'],
          fallback: "style-loader"
        })
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin('assets/style.css', { allChunks: true })
  ],
  resolve: {
    extensions: ['.js', '.jsx']
  }
};
