CATARSE.LayoutsApplicationView = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this, "render")
    //CATARSE.router.route("about", "about", this.about)
    this.render()
  },

  events: {
    "submit .search": "search"
  },
  
  search: function(event) {
    var query = this.$(event.target).find("#search").val()
    if(!(CATARSE.loader.namespace.text == "" && CATARSE.loader.controller == "explore" && CATARSE.loader.action == "index") && query.length > 0)       
      location.href = "/explore#search/" + query
    return false
  }

})
