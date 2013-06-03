var Skull = { View: undefined };
Skull.View = Backbone.View.extend({
  addView: function(name, view){
    this['_' + name] = new view({name: name, parent: this});
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
    _.each(this.constructor.views, function(val, key){
      var name = key.toLowerCase();
      this.__defineGetter__(name, function(){
        return (this['_' + name] ? this['_' + name] : this.addView(name, val));
      });
      // Initialize the view if the el is present in the parent's DOM subtree
      if(this.$(val.el).length > 0) this[name];
    }, this);
  },

  // Fetch and render template when the root el is empty
  // otherwise just render using ModelBinder
  show: function(){
    if($.trim(this.$el.html()).length == 0){
      this.fetchTemplate();
    }
    else{
      this.render();
    }
    return this;
  },

  fetchTemplate: function(){
    return $.get('/templates/' + this.name).success(this.renderTemplate);
  },

  renderTemplate: function(data){
    this.$el.html(data);
    this.render();
  }
},
// Static methods
{
  // We just overwrite the extend to extract the el property and store it in the constructor
  // That's how we look for the view's el before initializing it
  extend: function(protoProps, staticProps){
    var child = Backbone.View.extend.call(this, protoProps, staticProps);
    child.el = protoProps.el;
    return child;
  }
});

Skull.View.constructor.prototype.views = {};
