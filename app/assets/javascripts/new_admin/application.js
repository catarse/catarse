//= require mithril
//= require underscore
//= require mithril.postgrest
//= require moment
//= require new_admin/init
//= require catarse_admin
//= require_self

var adminRoot = document.getElementById("new-admin");
m.module(adminRoot, adminApp.AdminContributions);

window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};

