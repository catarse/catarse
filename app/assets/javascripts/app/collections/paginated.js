CATARSE.PaginatedCollection = Backbone.Collection.extend({
  initialize: function(options){
    typeof(options) != 'undefined' || (options = {})
    if(options.url)
      this.url = options.url
    if(options.search)
      this.search = options.search
    this.initializePages()
  },

  initializePages: function(){
    _.bindAll(this, "nextPage")
    this.page = 1
  },

  fetchPage: function(){
    return this.fetch({data: $.extend({page: this.page, locale: CATARSE.locale}, this.search)})
  },

  nextPage: function(){
    this.page++
    return this.fetchPage()
  }

})
