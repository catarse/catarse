//= require mithril
//= require underscore
//= require mithril.postgrest
//= require moment
//= require catarse-helpers
//= require static/init
//= require catarse-static
//= require_self

//TODO: don't forget to refact this for meta tag with data-api

var teamRoot = document.getElementById("team-root");

m.module(teamRoot, staticApp.Team);
