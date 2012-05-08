var CATARSE = {

  requireLogin: function(event, customUrl){
    event.preventDefault()
    var url = null
    if(typeof(customUrl) != 'undefined') {
      url = customUrl
    } else {
      if($(event.target).is('a')){
        url = $(event.target).attr('href')
      } else {
        url = $(event.target).parentsUntil('form').parent().attr('action')
      }
    }
    if(CATARSE.currentUser)
      location.href = url
    else
      location.href = "/login"
      //CATARSE.router.navigate("login/" + encodeURIComponent(url), true)
  },

  Common: {
    init: function(){
      CATARSE.locale = $(document.body).data("locale")
      CATARSE.currentUser = $(document.body).data("user")
      // Common init for every action
      CATARSE.router = new CATARSE.Router()
      CATARSE.layout = new CATARSE.LayoutsApplicationView({el: $('html')})
    },

    finish: function(){
      // Common finish for every action
      if (Backbone.history)
        Backbone.history.start()
    }
  },
  blog:{
    index: function(){
      window.view = new CATARSE.BlogIndexView({el: $("body") });
    }
  },

  projects: {
    index: function(){
      window.view = new CATARSE.ProjectsIndexView({el: $("body") });
    },
    show: function(){
      window.view = new CATARSE.ProjectsShowView({el: $("body") });
    }
  }
}
