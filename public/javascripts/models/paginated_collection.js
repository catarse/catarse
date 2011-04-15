var PaginatedCollection = Backbone.Collection.extend({
  action: "",
  controller: "",
  initialize: function(options){
    this.initializePages()
  },
  url: function(){
    return "/" + this.controller + "/" + this.action + ".json?page=" + this.page
  },
  initializePages: function(){
    _.bindAll(this, "nextPage")
    this.page = 1
  },
  nextPage: function(){
    this.page++
    this.fetch()
  }
})
