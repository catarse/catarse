//= require mithril/mithril
//= require_self
//= require_tree ./lib
//= require_tree ./components
//= require ./router
//= require ./init

var admin_app = window.admin_app = {};

admin_app.submodule = function(module, args) {
    return module.view.bind(this, new module.controller(args))
}