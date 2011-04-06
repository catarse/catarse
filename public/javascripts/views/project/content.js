var ProjectContentView = Backbone.View.extend({
  el: $('#project_content'),
  initialize: function(){
    this.setOptions()
    this.selectLink()
    this.render()
  },
  setOptions: function(defaults){
    this.template = this.options.template
    if(!this.template)
      this.template = defaults.template
    this.collection = this.options.collection
    if(!this.collection)
      this.collection = defaults.collection
    this.link = this.options.link
    if(!this.link)
      this.link = defaults.link
  },
  selectLink: function(){
    this.link.parent().parent().find('a').removeClass('selected')
    this.link.addClass('selected')
  },
  render: function() {
    $(this.el).html(Mustache.to_html(this.template.html(), this.collection))
    return this
  }
})