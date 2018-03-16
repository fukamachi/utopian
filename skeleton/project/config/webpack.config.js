var path = require('path');
var webpack = require('webpack');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: [
    'webpack-dev-server/client?http://localhost:8080',
    'webpack/hot/only-dev-server',
    path.join(__dirname, '..', 'assets/javascripts/main.js')
  ],
  output: {
    path: path.join(__dirname, '..', 'public'),
    filename: 'assets/bundle.js',
    publicPath: 'http://localhost:8080/'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            cacheDirectory: true
          }
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
    new webpack.HotModuleReplacementPlugin(),
    new ExtractTextPlugin('assets/style.css', { allChunks: true })
  ],
  resolve: {
    extensions: ['.js', '.jsx']
  },
  devServer: {
    host: 'localhost',
    port: 8080,
    historyApiFallback: true,
    hot: true,
    headers: { 'Access-Control-Allow-Origin': '*' }
  }
};
