var ModelView = Backbone.View.extend({
  initialize: function(){
    _.bindAll(this, "successDestroy", "errorDestroy")
    this.setOptions()
    this.render()
  },
  events: {
    "click .destroy a": "destroy"
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
    this.el.html(Mustache.to_html(this.template.html(), this.model))
    return this
  },
  destroy: function(event){
    event.preventDefault()
    this.model.destroy({success: this.successDestroy, error: this.errorDestroy})
  },
  successDestroy: function(model, response){
    var countTag = this.options.contentView.link.find('.count')
    var count = /^\((\d+)\)$/.exec(countTag.html())
    count = parseInt(count[1])
    countTag.html("(" + (count-1) + ")")
    this.el.slideUp()
  },
  errorDestroy: function(model, response){
    alert("Ooops! Ocorreu um erro ao excluir seu comentário. Por favor, tente novamente.")
  }
})