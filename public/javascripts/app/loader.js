/*!
  * $script.js Async loader & dependency manager
  * https://github.com/ded/script.js
  * (c) Dustin Diaz, Jacob Thornton 2011
  * License: MIT
  */
!function(a,b){typeof define=="function"?define(b):typeof module!="undefined"?module.exports=b():this[a]=b()}("$script",function(){function s(a,b,c){for(c=0,j=a.length;c<j;++c)if(!b(a[c]))return m;return 1}function t(a,b){s(a,function(a){return!b(a)})}function u(a,b,c){function o(a){return a.call?a():f[a]}function p(){if(!--m){f[l]=1,j&&j();for(var a in h)s(a.split("|"),o)&&!t(h[a],o)&&(h[a]=[])}}a=a[n]?a:[a];var e=b&&b.call,j=e?b:c,l=e?a.join(""):b,m=a.length;return setTimeout(function(){t(a,function(a){if(k[a])return l&&(g[l]=1),k[a]==2&&p();k[a]=1,l&&(g[l]=1),v(!d.test(a)&&i?i+a+".js":a,p)})},0),u}function v(a,d){var e=b.createElement("script"),f=m;e.onload=e.onerror=e[r]=function(){if(e[p]&&!/^c|loade/.test(e[p])||f)return;e.onload=e[r]=null,f=1,k[a]=2,d()},e.async=1,e.src=a,c.insertBefore(e,c.firstChild)}var a=this,b=document,c=b.getElementsByTagName("head")[0],d=/^https?:\/\//,e=a.$script,f={},g={},h={},i,k={},l="string",m=!1,n="push",o="DOMContentLoaded",p="readyState",q="addEventListener",r="onreadystatechange";return!b[p]&&b[q]&&(b[q](o,function w(){b.removeEventListener(o,w,m),b[p]="complete"},m),b[p]="loading"),u.get=v,u.order=function(a,b,c){(function d(e){e=a.shift(),a.length?u(e,d):u(e,b,c)})()},u.path=function(a){i=a},u.ready=function(a,b,c){a=a[n]?a:[a];var d=[];return!t(a,function(a){f[a]||d[n](a)})&&s(a,function(a){return f[a]})?b():!function(a){h[a]=h[a]||[],h[a][n](b),c&&c(d)}(a.join("|")),u},u.noConflict=function(){return a.$script=e,this},u})

/*
 * Catarse JS loader
 * Should be the only file included from views
 */

var CATARSE_LOADER = {

  initial: ['jquery-1.4.4.min', 'underscore-min'],
  
  intermediate: ['backbone-min', 'mustache', 'jquery-ui-1.8.6.custom.min', 'jquery.numeric', 'jquery.maxlength', 'jquery.timers-1.2', 'timedKeyup', 'waypoints.min', 'jquery.scrollto', 'jquery.jeditable.mini', 'jquery.maskedinput-1.2.2.min', 'jquery.cpf'],
  
  final: ['jquery.ui.datepicker-pt-BR', 'on_the_spot'],
  
  catarse: [
    'app/catarse',
    'app/views/layouts/pre_header',
    'app/views/layouts/flash',
    'app/views/layouts/login',
    'app/views/layouts/user',
  ],
  
  scriptURI: function(path){
    return '/javascripts/' + path + '.js';
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
          CATARSE_LOADER.load(CATARSE_LOADER.catarse, 'catarse')
          $script.ready('catarse', function(){
            $(document).ready(CATARSE_LOADER.loadAction);
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
        var controller = CATARSE_LOADER.namespace[CATARSE_LOADER.controller]
        if(!controller)
          controller = {}
        controller[CATARSE_LOADER.action] = new View()
      }
    }
    CATARSE_LOADER.exec(CATARSE, "common", "finish");
  },

  loadAction: function(){

    var body = $(document.body)
    
    CATARSE_LOADER.namespace = {}
    CATARSE_LOADER.namespace.text = body.data("namespace")
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
