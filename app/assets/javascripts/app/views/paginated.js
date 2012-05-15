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
    _.bindAll(this, "render", "update", "nextPage", "waypoint", "destroy", "beforeUpdate", "afterUpdate")
    this.render()
    this.loading.children().show()
    this.collection.page = 1
    this.collection.bind("reset", this.update)
    this.collection.fetchPage()
  },

  destroy: function() {
    this.loading.waypoint('destroy')
    this.collection.unbind("reset")
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
    this.el.html(_.template(this.template()))
    return this
  },

  afterUpdate: function(){
  },
  
  beforeUpdate: function(){
  },
  
  update: function(){
    this.beforeUpdate()
    this.loading.children().hide()
		ul_element = this.el.find("ul.collection_list")
    if(!this.collection.isEmpty()) {
      this.collection.each(function(model, i){
        var item = $("<li class='"+(i%3==0?'first':'')+""+(i%3==2?'last':'')+"'>")
        ul_element.append(item)
        new this.modelView({el: item, model: model})
      }, this)
    } else if(this.collection.page == 1) {
      this.el.html(_.template(this.emptyTemplate()))
    }
    this.afterUpdate()
    this.loading.waypoint(this.waypoint, {offset: "100%"})
    return this
  }

})
