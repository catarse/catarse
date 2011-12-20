var PaginatedCollection = Backbone.Collection.extend({
	baseUrl: "",
  initialize: function(options){
    typeof(options) != 'undefined' || (options = {})
		this.baseUrl = this.url
    this.initializePages()
  },
	url: function() {
		console.log("url: "+this.page)
		return this.document.url + '?' + $.param({page: this.page});
	},
  // url: function(){
  //   var url = this.baseUrl
  //   if(url.charAt(0) == "/")
  //     url = url.slice(1)
  //   url = "/" + app.locale + "/" + url + "?" + $.param({page: this.page})
  //   if(this.search)
  //     url = url + '&' + $.param({search: this.search})
  //   return url
  // },
  initializePages: function(){
    _.bindAll(this, "nextPage")
    this.page = 1
		console.log("initializePages: "+this.page)
  },
  nextPage: function(){
    this.page++
		// this.url = this.baseUrl + '?' + $.param({page: this.page});
    return this.fetch()
  }
})
