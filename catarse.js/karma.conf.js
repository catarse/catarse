process.env.CHROME_BIN = require('puppeteer').executablePath()

const webpack = require('./webpack.config');

delete webpack['entry'];
delete webpack['output'];
delete webpack['plugins'];

module.exports = (config) => {
    config.set({
        basePath: '',
        frameworks: ['jasmine'],
        files: [
            'legacy/spec/lib/jasmine-matchers.js',
            'node_modules/jasmine-ajax/lib/mock-ajax.js',
            'node_modules/jasmine-species/jasmine-grammar.js',
            'legacy/spec/lib/i18n/i18n.js',
            'legacy/spec/lib/analytics.js',
            'node_modules/mithril/mithril.js',
            'node_modules/underscore/underscore.js',
            'node_modules/mithril-postgrest/mithril-postgrest.umd.js',
            'node_modules/chart.js/Chart.js',
            'node_modules/moment/moment.js',
            'legacy/vendor/replaceDiacritics.js',
            'legacy/spec/lib/mocks/*mock.js',
            'legacy/spec/index.spec.js',
        ],
        preprocessors: {
            'legacy/spec/lib/mithril-query/mithril-query.js' : ['webpack'],
            'legacy/spec/**/*.spec.js': ['webpack'],
            'legacy/spec/index.spec.js': ['webpack']
        },
        webpack,
        exclude: [],
        reporters: ['spec'],
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        browsers: ['MyHeadlessChrome'],
        customLaunchers: {
            MyHeadlessChrome: {
                base: 'ChromeHeadless',
                flags: ['--headless', '--no-sandbox']
            }
        },
        singleRun: true
    });
};
