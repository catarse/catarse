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
      CATARSE.locale = $('#main_content').data("locale")
      CATARSE.currentUser = $('#main_content').data("user")
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
  explore:{
    index: function(){
       window.view = new CATARSE.ExploreIndexView({el: $("body") });
    }
  },
  projects: {
    index: function(){
      window.view = new CATARSE.ProjectsIndexView({el: $("body") });
    },
    show: function(){
      window.view = new CATARSE.ProjectsShowView({el: $("body") });
    },
    embed: function(){
      window.view = new CATARSE.ProjectsEmbedView({el: $("body") });
    },
    video_embed: function(){
      window.view = new CATARSE.ProjectsVideo_embedView({el: $("body") });
    },
    'new': function(){
      window.view = new CATARSE.ProjectsNewView({el: $("body") });
    },
    pending: function(){
      window.view = new CATARSE.ProjectsPendingView({el: $("body") });
    },
    pending_backers: function(){
      window.view = new CATARSE.ProjectsPending_backersView({el: $("body") });
    },
    start: function(){
      window.view = new CATARSE.ProjectsStartView({el: $("body") });
    },
    backers: {
      'new': function(){
        window.view = new CATARSE.BackersNewView({el: $("body") });
      },
      review: function(){
        window.view = new CATARSE.BackersReviewView({el: $("body") });
      }
    }
  },
  static: {
    guidelines: function(){
      window.view = new CATARSE.StaticGuidelinesView({el: $("body") });
    }
  },
  users: {
    show: function(){
      window.view = new CATARSE.UsersShowView({el: $("body") });
    }
  }
}
