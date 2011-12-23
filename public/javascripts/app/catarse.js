var CATARSE = {

  loader: CATARSE_LOADER,
  locale: $(document.body).data("locale"),
  currentUser: $(document.body).data("user"),
  
  common:{
    init: function(){
      // Common init for every action
    },

    finish: function(){
      // Common finish for every action
      if (Backbone.history)
        Backbone.history.start()
    }
  }

}
