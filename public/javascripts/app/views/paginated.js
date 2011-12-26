CATARSE.PaginatedView = Backbone.View.extend({

  initialize: function(options){
    typeof(options) != 'undefined' || (options = {})
    if(options.collection)
      this.collection = options.collection
    if(options.modelView)
      this.modelView = options.modelView
    if(options.emptyTemplate)
      this.emptyTemplate = options.emptyTemplate
    if(options.loading)
      this.loading = options.loading
		this.loading = $("#loading")
    this.loading.waypoint('destroy')
    _.bindAll(this, "render", "update", "nextPage", "waypoint")
    this.render()
		this.loading.children().show()
    this.collection.page = 1
    this.collection.bind("reset", this.update)
    this.collection.fetchPage()
  },

  waypoint: function(event, direction){
    if(!this.loading.children().is(":visible")){
      this.loading.waypoint('remove')
      if(direction == "down")
        this.nextPage()
    }
  },

  nextPage: function(){
    if(!this.collection.isEmpty()) {
      this.loading.children().show()
      this.collection.nextPage()
    }
		return this
  },

  render: function() {
    this.el.html("")
    return this
  },

  update: function(){
    this.loading.children().hide()
    if(!this.collection.isEmpty()) {
      this.collection_list = $('<ul class="collection_list">')
      this.el.append(this.collection_list)
      this.collection.each(function(model){
        var item = $('<li>')
        this.collection_list.append(item)
        new this.modelView({el: item, model: model})        
      }, this)
    } else if(this.collection.page == 1) {
      this.el.html(this.emptyTemplate())
    }
    this.loading.waypoint(this.waypoint, {offset: "100%"})
    return this
  }

})
