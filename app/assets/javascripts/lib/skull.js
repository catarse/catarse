var Skull = { View: undefined };
Skull.View = Backbone.View.extend({
  addView: function(name, view){
    if(!this['_' + name]){
      this['_' + name] = new view({name: name, parent: this});
    }
    return this['_' + name];
  },

  rootView: function(){
    var view = this;
    var root = view;
    while(view = view.parent){
      root = view;
    }
    return root;
  },

  router: function(){
    return this.rootView().router;
  },

  route: function(route){
    var that = this;
    return this.router().route(route, route, function(){ that.followRoute(route, route.split("/")[0], arguments); });
  },

  initialize: function(options){
    _.bindAll(this);
    if(options){
      this.name = options.name;
      this.parent = options.parent;
    }

    if(_.isFunction(this.beforeActivate)){
      this.beforeActivate();
    }

    this.createViewGetters();

    if(_.isFunction(this.activate)){
      this.activate();
    }
  },

  navigate: function(url){
    window.location.href = url;
  },

  // Create a getter to initilize each view defined in the constructor when needed
  createViewGetters: function(){
    _.each(Object.getPrototypeOf(this).constructor.views, function(val, key){
      var name = key[0].toLowerCase() + key.substring(1);
      Object.defineProperty(this, name, {
        configurable: true,
        enumerable: true,
        get: function(){
          return this.addView(name, val);
        }
      });
      // Initialize the view if the el is present in the parent's DOM subtree
      if(this.$(val.el).length > 0) this[name];
    }, this);
  }
},
// Static methods
{
  // We just overwrite the extend to extract the el property and store it in the constructor
  // That's how we look for the view's el before initializing it
  views: {},
  addChild: function(name, protoProps, staticProps){
    var child = Skull.View.extend(protoProps, _.extend({views: {}}, staticProps));
    child.el = protoProps.el;
    this.views[name] = child;
    return this;
  }
});

