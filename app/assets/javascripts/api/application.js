//= require mithril/mithril.min.js
//= require jquery
//= require select
//= require underscore/underscore-min.js
//= require liquidjs/dist/liquid.min.js
//= require mithril-postgrest
//= require moment/min/moment.min.js
//= require lib/replace-diacritics
//= require chart.js/Chart.min.js
//= require i18n/translations
//= require ../analytics
//= require catarse.js/dist/catarse.js
//= require_self


window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};
