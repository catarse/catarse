jQuery(function () {
  var body, controllerClass, controllerName, action;

  body = $(document.body);
  controllerClass = body.data( "controller-class" );
  controllerName = body.data( "controller" );
  action = body.data( "action" );

  function exec(controllerClass, controllerName, action) {
    var ns, railsNS;

    ns = CATARSE;
    railsNS = controllerClass ? controllerClass.split("::").slice(0, -1) : [];

    _.each(railsNS, function(name){
      if(ns) {
        ns = ns[name];
      }
    });

    if ( ns && controllerName && controllerName !== "" ) {
      if(ns[controllerName] && _.isFunction(ns[controllerName][action])) {
        var view = window.view = new ns[controllerName][action]();
      }
    }
  }

  function exec_filter(filterName){
    if(CATARSE.Common && _.isFunction(CATARSE.Common[filterName])){
      CATARSE.Common[filterName]();
    }
  }

  exec_filter('init');
  exec( controllerClass, controllerName, action );
  exec_filter('finish');
  $.ajaxSetup({ dataType: 'html' });
});
