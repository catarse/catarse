var Skull = { View: undefined };
Skull.View = Backbone.View.extend({
  addView: function(name, view){
    if(!this['_' + name]){
      this['_' + name] = new view({name: name, parent: this});
    }
    return this['_' + name];
  },

  initialize: function(options){
    _.bindAll(this);
    if(options){
      this.name = options.name;
      this.parent = options.parent;
    }

    this.createViewGetters();

    if(_.isFunction(this.activate)){
      this.activate();
    }
  },

  // Create a getter to initilize each view defined in the constructor when needed
  createViewGetters: function(){
    _.each(this.__proto__.constructor.views, function(val, key){
      var name = key[0].toLowerCase() + key.substring(1);
      this.__defineGetter__(name, function(){
        return this.addView(name, val);
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

