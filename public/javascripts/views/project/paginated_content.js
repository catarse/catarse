var ProjectPaginatedContentView = ProjectContentView.extend({
  initialize: function(){
    $('#loading').waypoint('destroy')
    _.bindAll(this, "render", "nextPage", "waypoint")
    this.setOptions()
    this.selectLink()
    $(this.el).html(null)
    $('#loading img').show()
    this.collection.page = 1
    this.collection.bind("refresh", this.render)
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
    $('#loading img').hide()
    if(this.collection.page == 1 || !this.collection.isEmpty())
      $(this.el).append(Mustache.to_html(this.template.html(), this.collection))
    $('#loading').waypoint(this.waypoint, {offset: "100%"})
    return this
  }
})
