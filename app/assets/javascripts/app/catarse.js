var CATARSE = {
  Adm: {},
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
      $(".best_in_place").best_in_place();

      CATARSE.Common.trackUserClicksInHomePage();
    },
    
    trackUserClicksInHomePage: function(){

      var namespace = $('body');
      var user      = ( namespace.data('user') != null ) ? namespace.data('user').id : null;

      $('.project_content h4').on('click', function(){ 
        mixpanel.track(
          "Clicked on a project's link box",
          { 'page name': document.title, 'user_id': user, 'project': $(this).attr('href'), 'url': window.location }
        );
      });
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
  adm: {
    users:{
      index: function(){
        window.view = new CATARSE.Adm.Users.Index({el: $("body") });
      }
    },

    projects:{
      index: function(){
        window.view = new CATARSE.Adm.Projects.Index({el: $('body')});
      }
    },

    backers:{
      index: function(){
        window.view = new CATARSE.Adm.Backers.Index({el: $("body") });
      }
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
      return new CATARSE.ProjectsNewView();
    },
    create: function(){
      return new CATARSE.ProjectsNewView();
    },
    pending: function(){
      window.view = new CATARSE.ProjectsPendingView({el: $("body") });
    },
    pending_backers: function(){
      window.view = new CATARSE.ProjectsPending_backersView({el: $("body") });
    },
    backers: {
      'new': function(){
        window.view = new CATARSE.BackersNewView({el: $("body") });
      },
      create: function(){
        window.view = new CATARSE.BackersCreateView({el: $("body") });
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
