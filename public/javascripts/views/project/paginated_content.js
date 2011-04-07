var ProjectPaginatedContentView = ProjectContentView.extend({
  initialize: function(){
    $('#loading').waypoint('destroy')
    _.bindAll(this, "render", "update", "nextPage", "waypoint", "successCreate", "errorCreate")
    this.setOptions()
    this.selectLink()
    this.render()
    $('#loading img').show()
    this.collection.page = 1
    this.collection.bind("refresh", this.update)
    this.collection.fetch()
    $('#loading').waypoint(this.waypoint, {offset: "100%"})
  },
  waypoint: function(event, direction){
    $('#loading').waypoint('remove')
    if(direction == "down")
      this.nextPage()
  },
  nextPage: function(){
    if(!this.collection.isEmpty()) {
      $('#loading img').show()
      this.collection.nextPage()
    }
  },
  render: function() {
    $(this.el).html(Mustache.to_html(this.template.html(), this.collection))
    return this
  },
  update: function(){
    $('#loading img').hide()
    if(!this.collection.isEmpty()) {
      this.collection.each(function(model){
        var listItem = $('<li>')
        this.$('ul').append(listItem)
        new this.modelView({el: listItem, model: model, contentView: this})        
      }, this)
    } else if(this.collection.page == 1) {
      $(this.el).append(this.emptyText)
    }
    $('#loading').waypoint(this.waypoint, {offset: "100%"})
    return this
  },
  successCreate: function(model, response){
  },
  errorCreate: function(model, response){
  }
})
