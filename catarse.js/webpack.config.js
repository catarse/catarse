const path = require('path');
const webpack = require('webpack');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');

const isProd = process.env.NODE_ENV === 'production';

const ifDefOpts = {
    DEBUG: !isProd,
    version: 3,
    'ifdef-verbose': true,
};

module.exports = {
    entry: './legacy/src/app.js',
    mode: isProd ? 'production' : 'development',
    module: {
        rules: [
            {
                test: /\.[jt]sx?$/,
                exclude: /node_modules/,

                use: [
                    {
                        loader: 'babel-loader',
                        options: {
                            cacheDirectory: true
                        }
                    },
                    {
                        loader: 'ifdef-loader',
                        options: ifDefOpts,
                    },
                ],
            },
            {
                test: /\.css$/,
                exclude: /node_modules/,
                use: ['style-loader', 'css-loader']
            },
            {
                test: /\.s[ac]ss$/i,
                exclude: /node_modules/,
                use: [
                    // Creates `style` nodes from JS strings
                    'style-loader',
                    // Translates CSS into CommonJS
                    'css-loader',
                    {
                        // Compiles Sass to CSS
                        loader: 'sass-loader',
                        options: {
                            sassOptions: {
                                indentWidth: 4,
                                includePaths: ['../../stylesheets/catarse_bootstrap/'],
                            },
                        },
                    }
                ],
            },
        ],
    },
    resolve: {
        extensions: ['.tsx', '.ts', '.jsx', '.js'],
        alias: {
            '@': path.resolve(__dirname, 'legacy/src')
        }
    },
    devServer: {
        contentBase: './dist',
    },
    devtool: 'source-map',
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'catarse.js',
        sourceMapFilename: 'catarse.js.map',
    },
    plugins: isProd ? [new UglifyJsPlugin({
        sourceMap: true,
        uglifyOptions: {
            compress: false
        }
    })] : [],
};
