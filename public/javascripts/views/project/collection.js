var CollectionView = Backbone.View.extend({
  initialize: function(){
    this.setOptions()
    this.render()
  },
  setOptions: function(defaults){
    if(this.options.template)
      this.template = this.options.template
    if(!this.template)
      this.template = defaults.template
    this.collection = this.options.collection
    if(!this.collection)
      this.collection = defaults.collection
  },
  render: function() {
    this.el.append(Mustache.to_html(this.template.html(), this.collection))
    return this
  }
})