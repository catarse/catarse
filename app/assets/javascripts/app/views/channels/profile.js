CATARSE.channels = {
 
  profiles: {
    index: Backbone.View.extend({


      initialize: function(){


        this.banner = $('.call_to_action'),
        this.setupBackground();
      },

      setupBackground: function(){
        this.banner.css({"background": 'url("' + 
                        this.banner.data('background') + '") no-repeat center',
                      'opacity': 1 
        });
      },
    }),
  }


}
