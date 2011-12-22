var PaginatedCollection = Backbone.Collection.extend({
	
  initialize: function(options){
    typeof(options) != 'undefined' || (options = {})
    this.initializePages()
  },
  initializePages: function(){
    _.bindAll(this, "nextPage")
    this.page = 1
  },
  nextPage: function(){
    this.page++
    return this.fetch({data: {page: this.page, locale: locale}})
  }
})
