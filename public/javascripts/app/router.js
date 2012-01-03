CATARSE.Router = Backbone.Router.extend({

  initialize: function(options){
    _.bindAll(this, "hashChange", "back", "currentPath", "lastPath")
    this.history = [this.currentPath()]
    $(window).bind('hashchange', this.hashChange)
  },
  
  currentPath: function() {
    var path = location.pathname + location.hash
    if(!/#/.test(path))
      path = path + "#"
    return path
  },
  
  lastPath: function() {
    var path = this.history[this.history.length - 2]
    if(!path)
      path = "#"
    return path
  },
  
  hashChange: function() {
    this.history.push(this.currentPath())
  },
  
  back: function() {
    location.href = this.lastPath()
  }
  
})
