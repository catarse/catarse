var Comment = Backbone.Model.extend()
var Comments = Backbone.Collection.extend({
  model: Comment,
  initialize: function(options){
    _.bindAll(this, "nextPage")
    this.page = 1
    this.project = options.project
  },
  url: function(){
    return "/projects/" + this.project.get('id') + "/comments?page=" + this.page
  },
  nextPage: function(){
    this.page++
    this.fetch()
  }
})
