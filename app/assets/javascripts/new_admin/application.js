//= require mithril
//= require underscore
//= require mithril.postgrest
//= require new_admin/init
//= require catarse_admin
//= require_self

var adminRoot = document.getElementById("new-admin")
<<<<<<< HEAD
m.postgrest.init(adminRoot.getAttribute('data-api'), {method: "GET", url: "/api_token"});
m.module(adminRoot, adminApp.AdminContributions);
=======

m.module(adminRoot, adminApp.AdminContributions);
>>>>>>> Fixes new_admin dependency problems
