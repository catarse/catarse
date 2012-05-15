CATARSE.ModelView = Backbone.View.extend({
  
  initialize: function(){
    typeof(options) != 'undefined' || (options = {})
    if(options.template)
      this.template = options.template
    _.bindAll(this, "render", "beforeRender", "afterRender")
    this.render()
  },
  
  beforeRender: function() {
  },
  
  afterRender: function() {
  },
  
  render: function() {
    this.beforeRender()
    this.el.html(_.template(this.template(), this.model.toJSON()))
    this.afterRender()
    return this
  }
  
})
