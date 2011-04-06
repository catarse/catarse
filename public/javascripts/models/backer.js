var Backer = Backbone.Model.extend()
var Backers = Backbone.Collection.extend({
  model: Backer,
  initialize: function(options){
    _.bindAll(this, "nextPage")
    this.page = 1
    this.project = options.project
  },
  url: function(){
    return "/projects/" + this.project.get('id') + "/backers?page=" + this.page
  },
  nextPage: function(){
    this.page++
    this.fetch()
  }
})
