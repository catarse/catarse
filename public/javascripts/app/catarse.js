CATARSE = {

  common:{
    init: function(){
      // Common init for every action
    },

    finish: function(){
      // Common finish for every action
      if (Backbone.history)
        Backbone.history.start();
    }
  }

};
