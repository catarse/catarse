CATARSE.channels = {
 
  profiles: {
    show: Backbone.View.extend({
  

      el: 'body',

      initialize: function(){


        this.banner = this.$('.call_to_action'),
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
