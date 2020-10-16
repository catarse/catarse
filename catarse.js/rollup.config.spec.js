import babel from 'rollup-plugin-babel';
import multiEntry from 'rollup-plugin-multi-entry';

//This is the standalone rollup config file to bundle the specs.
//With rollup installed globally in your environment, you can simple run `rollup -c rollup.config.spec.js`

export default {
  entry: ['spec/components/**/*.spec.js', 'src/**/*.js'],
  dest: 'spec/bundle.spec.js',
  sourceMap: true,
  format: 'iife',
  moduleName: 'catarseSpecs',
  plugins: [babel(), multiEntry()],
  globals: {
      underscore: '_',
      moment: 'moment',
      mithril: 'm',
      liquidjs: 'Liquid',
      'chartjs': 'Chart',
      'replaceDiacritics': 'replaceDiacritics',
      'mithril-postgrest': 'Postgrest',
      'i18n-js': 'I18n'
  }
};
