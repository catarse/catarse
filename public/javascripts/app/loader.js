/*!
  * $script.js Async loader & dependency manager
  * https://github.com/ded/script.js
  * (c) Dustin Diaz, Jacob Thornton 2011
  * License: MIT
  */

// Commented this line and created my own withou cacheing. Good for dev environment

// !function(a,b){typeof define=="function"?define(b):typeof module!="undefined"?module.exports=b():this[a]=b()}("$script",function(){function s(a,b,c){for(c=0,j=a.length;c<j;++c)if(!b(a[c]))return m;return 1}function t(a,b){s(a,function(a){return!b(a)})}function u(a,b,c){function o(a){return a.call?a():f[a]}function p(){if(!--m){f[l]=1,j&&j();for(var a in h)s(a.split("|"),o)&&!t(h[a],o)&&(h[a]=[])}}a=a[n]?a:[a];var e=b&&b.call,j=e?b:c,l=e?a.join(""):b,m=a.length;return setTimeout(function(){t(a,function(a){if(k[a])return l&&(g[l]=1),k[a]==2&&p();k[a]=1,l&&(g[l]=1),v(!d.test(a)&&i?i+a+".js":a,p)})},0),u}function v(a,d){var e=b.createElement("script"),f=m;e.onload=e.onerror=e[r]=function(){if(e[p]&&!/^c|loade/.test(e[p])||f)return;e.onload=e[r]=null,f=1,k[a]=2,d()},e.async=1,e.src=a,c.insertBefore(e,c.firstChild)}var a=this,b=document,c=b.getElementsByTagName("head")[0],d=/^https?:\/\//,e=a.$script,f={},g={},h={},i,k={},l="string",m=!1,n="push",o="DOMContentLoaded",p="readyState",q="addEventListener",r="onreadystatechange";return!b[p]&&b[q]&&(b[q](o,function w(){b.removeEventListener(o,w,m),b[p]="complete"},m),b[p]="loading"),u.get=v,u.order=function(a,b,c){(function d(e){e=a.shift(),a.length?u(e,d):u(e,b,c)})()},u.path=function(a){i=a},u.ready=function(a,b,c){a=a[n]?a:[a];var d=[];return!t(a,function(a){f[a]||d[n](a)})&&s(a,function(a){return f[a]})?b():!function(a){h[a]=h[a]||[],h[a][n](b),c&&c(d)}(a.join("|")),u},u.noConflict=function(){return a.$script=e,this},u})

// Commented the line above and created my own withou cacheing. Good for dev environment
(function(a,b,c){typeof c["module"]!="undefined"&&c.module.exports?c.module.exports=b():typeof c["define"]!="undefined"&&c["define"]=="function"&&c.define.amd?define(a,b):c[a]=b()})("$script",function(){function p(a,b){for(var c=0,d=a.length;c<d;++c)if(!b(a[c]))return j;return 1}function q(a,b){p(a,function(a){return!b(a)})}function r(a,b,i){function o(a){return a.call?a():d[a]}function t(){if(!--n){d[m]=1,l&&l();for(var a in f)p(a.split("|"),o)&&!q(f[a],o)&&(f[a]=[])}}a=a[k]?a:[a];var j=b&&b.call,l=j?b:i,m=j?a.join(""):b,n=a.length;return setTimeout(function(){q(a,function(a){if(h[a])return m&&(e[m]=1),h[a]==2&&t();h[a]=1,m&&(e[m]=1),s(!c.test(a)&&g?g+a+".js":a,t)})},0),r}function s(c,d){var e=a.createElement("script"),f=j;e.onload=e.onerror=e[o]=function(){if(e[m]&&!/^c|loade/.test(e[m])||f)return;e.onload=e[o]=null,f=1,h[c]=2,d()},e.async=1,e.src=c,b.insertBefore(e,b.firstChild)}var a=document,b=a.getElementsByTagName("head")[0],c=/^https?:\/\//,d={},e={},f={},g,h={},i="string",j=!1,k="push",l="DOMContentLoaded",m="readyState",n="addEventListener",o="onreadystatechange";return!a[m]&&a[n]&&(a[n](l,function t(){a.removeEventListener(l,t,j),a[m]="complete"},j),a[m]="loading"),r.get=s,r.order=function(a,b,c){(function d(e){e=a.shift(),a.length?r(e,d):r(e,b,c)})()},r.path=function(a){g=a},r.ready=function(a,b,c){a=a[k]?a:[a];var e=[];return!q(a,function(a){d[a]||e[k](a)})&&p(a,function(a){return d[a]})?b():!function(a){f[a]=f[a]||[],f[a][k](b),c&&c(e)}(a.join("|")),r},r},this)

/*
 * Catarse JS loader
 * Should be the only file included from views
 */
var CATARSE_LOADER = window.CATARSE_LOADER = {

  initial: ['jquery-1.7.1.min', 'underscore-min'],

  intermediate: ['backbone-min', 'mustache', 'jquery-ui-1.8.6.custom.min', 'jquery.numeric', 'jquery.maxlength', 'jquery.timers-1.2', 'timedKeyup', 'waypoints.min', 'jquery.scrollto', 'jquery.jeditable.mini', 'jquery.maskedinput-1.2.2.min', 'jquery.cpf', 'twitter', 'jquery_ujs'],

  final: ['jquery.ui.datepicker-pt-BR', 'on_the_spot', 'app/catarse', 'bootstrap'],

  catarse: {

    initial: [
      'app/router'
    ],

    intermediate: [
      'app/views/layouts/application',
      'app/models/project',
      'app/models/backer',
      'app/models/user',
      'app/models/user_back',
      'app/models/user_project',
      'app/collections/paginated',
      'app/views/model',
      'app/views/paginated'
    ],

    final: [
      'app/collections/projects',
      'app/collections/backers',
      'app/collections/user_backs',
      'app/collections/user_projects'
    ]
  },

  scriptURI: function(path){
    return '/javascripts/' + path + '.js?' + new Date().getTime();
  },

  scriptURIs: function(paths){
    var result = new Array()
    var len = paths.length
    for(var i=0; i<len; i++) {
      result[i] = this.scriptURI(paths[i])
    }
    return result
  },

  load: function(what, name){
    if(typeof what == "object") {
      $script(this.scriptURIs(what), name)
    } else if(typeof what == "string") {
      $script(this.scriptURI(what), name)
    }
  },

  init: function(){
    this.load(this.initial, 'initial')
    $script.ready('initial', function(){
      CATARSE_LOADER.load(CATARSE_LOADER.intermediate, 'intermediate')
      $script.ready('intermediate', function(){
        CATARSE_LOADER.load(CATARSE_LOADER.final, 'final')
        $script.ready('final', function(){
          CATARSE_LOADER.load(CATARSE_LOADER.catarse.initial, 'catarse.initial')
          $script.ready('catarse.initial', function(){
            CATARSE_LOADER.load(CATARSE_LOADER.catarse.intermediate, 'catarse.intermediate')
            $script.ready('catarse.intermediate', function(){
              CATARSE_LOADER.load(CATARSE_LOADER.catarse.final, 'catarse.final')
              $script.ready('catarse.final', function(){
                $(document).ready(CATARSE_LOADER.loadAction);
              })
            })
          })
        })
      })
    })
  },

  exec: function(namespace, controller, action) {
    if ( namespace && namespace[controller] && typeof namespace[controller][action] == "function" ) {
      namespace[controller][action]();
      return true;
    } else {
      return false;
    }
  },

  expandNamespace: function(object, list) {
    var name = list.shift()
    if (object[name])
      return CATARSE_LOADER.expandNamespace(object[name], list)
    else
      return object
  },

  viewName: function() {
    var len = CATARSE_LOADER.namespace.list.push(CATARSE_LOADER.controller, CATARSE_LOADER.action, "View")
    var result = ""
    for(var i=0; i<len; i++) {
      result = result + CATARSE_LOADER.namespace.list[i].charAt(0).toUpperCase() + CATARSE_LOADER.namespace.list[i].slice(1)
    }
    return result
  },

  execAction: function() {
    CATARSE_LOADER.exec(CATARSE, "common", "init");
    CATARSE_LOADER.exec(CATARSE_LOADER.namespace.object, CATARSE_LOADER.controller, "init");
    if ( !CATARSE_LOADER.exec(CATARSE_LOADER.namespace.object, CATARSE_LOADER.controller, CATARSE_LOADER.action) ) {
      var View = CATARSE[CATARSE_LOADER.viewName()]
      if (View) {
        if(!CATARSE_LOADER.namespace.object[CATARSE_LOADER.controller])
          CATARSE_LOADER.namespace.object[CATARSE_LOADER.controller] = {}
        CATARSE_LOADER.namespace.object[CATARSE_LOADER.controller][CATARSE_LOADER.action] = new View({el: $("body") })
      }
    }
    CATARSE_LOADER.exec(CATARSE, "common", "finish");
  },

  loadAction: function(){
    var body = $('#main_content')
    var namespace_text = ""

    CATARSE_LOADER.namespace = {}
    if(body.data("namespace") != null) {
      namespace_text = body.data("namespace");
    }
    CATARSE_LOADER.namespace.text = namespace_text
    CATARSE_LOADER.namespace.list = CATARSE_LOADER.namespace.text.split("_")
    CATARSE_LOADER.namespace.folder = CATARSE_LOADER.namespace.list.join("/")
    if (CATARSE_LOADER.namespace.folder.length > 0)
      CATARSE_LOADER.namespace.folder = CATARSE_LOADER.namespace.folder + "/"
    CATARSE_LOADER.namespace.object = CATARSE_LOADER.expandNamespace(CATARSE, CATARSE_LOADER.namespace.list)

    CATARSE_LOADER.controller = body.data("controller")
    CATARSE_LOADER.action = body.data("action")

    CATARSE_LOADER.load("app/views/" + CATARSE_LOADER.namespace.folder + CATARSE_LOADER.controller + "/" + CATARSE_LOADER.action, 'action')

    $script.ready('action', function() {
      if (CATARSE.loader.dependencies) {
        $script.ready('dependencies', function() {
          CATARSE_LOADER.execAction()
        })
      } else {
        CATARSE_LOADER.execAction()
      }
    })

  }

}


CATARSE_LOADER.init()
