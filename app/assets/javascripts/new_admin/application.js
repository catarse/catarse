//= require mithril
//= require underscore
//= require mithril.postgrest
//= require moment
//= require new_admin/init
//= require catarse_admin
//= require_self

var adminRoot = document.getElementById("new-admin")
m.postgrest.init(adminRoot.getAttribute('data-api'), {method: "GET", url: "/api_token"});
m.module(adminRoot, adminApp.AdminContributions);

