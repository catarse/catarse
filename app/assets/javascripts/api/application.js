//= require mithril
//= require underscore
//= require mithril.postgrest
//= require moment
//= require replace-diacritics
//= require catarse-helpers
//= require api/init
//= require catarse-admin
//= require catarse-static
//= require_self

var adminRoot = document.getElementById("new-admin");
if(adminRoot)
  m.module(adminRoot, adminApp.AdminContributions);

var teamRoot = document.getElementById("team-root");
if(teamRoot)
  m.module(teamRoot, staticApp.Team);

window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};
