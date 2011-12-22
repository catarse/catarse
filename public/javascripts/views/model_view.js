var ModelView = Backbone.View.extend({
  initialize: function(){
    typeof(options) != 'undefined' || (options = {})
    if(options.template)
      this.template = options.template
    this.render()
  },
  render: function() {
		this.el.html(this.template(this.model.toJSON()))
    return this
  }
})
