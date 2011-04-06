var ModelView = Backbone.View.extend({
  initialize: function(){
    this.setOptions()
    this.render()
  },
  setOptions: function(defaults){
    if(this.options.template)
      this.template = this.options.template
    if(!this.template)
      this.template = defaults.template
    this.model = this.options.model
    if(!this.model)
      this.model = defaults.model
  },
  render: function() {
    this.el.prepend(Mustache.to_html(this.template.html(), this.model))
    return this
  }
})