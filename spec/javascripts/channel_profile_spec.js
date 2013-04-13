describe("Channels", function(){
  
  beforeEach(function(){
    window.CHANNEL = new CATARSE.channels.profiles.show();
  });
 



  describe("show action", function(){

    describe("subscribe", function(){
      beforeEach(function(){ 
        window.CHANNEL.subscribe();
      });

      it("", function(){
      });
    });


    describe("initialize", function(){
      beforeEach(function(){ 
        spyOn(window.CHANNEL, 'setupBackground');
        window.CHANNEL.initialize();
      });

      it("should call the function to change background when initializing the show action", function(){
        expect(window.CHANNEL.setupBackground).toHaveBeenCalled();
      });
    });
    // end initialize
    
    describe("setupBackground", function(){
      beforeEach(function(){
        spyOn($.fn, 'css');
        spyOn($.fn, 'data').andReturn('bg');
        window.CHANNEL.setupBackground();
      }); 

      it("should change the background based on the data-background attribute of .call_to_action div", function(){
        expect(window.CHANNEL.banner.css).toHaveBeenCalledWith({"background": 'url("bg") no-repeat center','opacity': 1 });
      });
    });

  });

});
