//= require mithril/mithril
//= require_self
//= require_tree ./components
//= require ./router
//= require ./init

var app = window.app = {};

app.submodule = function(module, args) {
    return module.view.bind(this, new module.controller(args))
}