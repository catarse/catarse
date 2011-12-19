var PaginatedCollection = Backbone.Collection.extend({
  baseUrl: "",
  search: "",
  initialize: function(options){
    typeof(options) != 'undefined' || (options = {})
    if(options.baseUrl)
      this.baseUrl = options.baseUrl
    if(options.search)
      this.search = options.search
    this.initializePages()
  },
  url: function(){
    var url = this.baseUrl
    if(url.charAt(0) == "/")
      url = url.slice(1)
    url = "/" + app.locale + "/" + url + "?" + $.param({page: this.page})
    if(this.search)
      url = url + '&' + $.param({search: this.search})
    return url
  },
  initializePages: function(){
    _.bindAll(this, "nextPage")
    this.page = 1
  },
  nextPage: function(){
    this.page++
    return this.fetch()
  }
})
