var ProjectPaginatedContentView = ProjectContentView.extend({
  initialize: function(){
    $('#loading').waypoint('destroy')
    _.bindAll(this, "render", "update", "nextPage", "waypoint", "success", "error")
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
    if(!this.collection.isEmpty())
      new this.collectionView({el: this.$('ul'), collection: this.collection})
    $('#loading').waypoint(this.waypoint, {offset: "100%"})
    return this
  },
  success: function(model, response){
  },
  error: function(model, response){
  }
})
