//= require mithril
//= require underscore
//= require mithril.postgrest
//= require moment
//= require replace-diacritics
//= require api/init
//= require hack-for-chinese/catarse.js
//= require_self

var adminRoot = document.getElementById('new-admin'),
    teamRoot = document.getElementById("team-root");

if(adminRoot){
  m.module(adminRoot, c.admin.Contributions);
}

if(teamRoot){
  m.module(teamRoot, c.pages.Team);
}

window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};
