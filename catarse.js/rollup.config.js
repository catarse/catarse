import babel from 'rollup-plugin-babel';

//This is the standalone rollup config file to bundle and build dist files.
//With rollup installed globally in your environment, you can simple run rollup -c.
export default {
  entry: 'src/c.js',
  dest: 'dist/catarse.js',
  sourceMap: true,
  format: 'iife',
  moduleName: 'c',
  plugins: [babel()],
  globals: {
      chartjs: 'Chart',
      mithril: 'm',
      'mithril-postgrest': 'Postgrest',
      moment: 'moment',
      'i18n-js': 'I18n',
      replaceDiacritics: 'replaceDiacritics',
      select: 'select',
      underscore: '_',
      liquidjs: 'Liquid'
  }
};
