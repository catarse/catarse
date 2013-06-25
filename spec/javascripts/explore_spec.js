describe("Explore", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Explore();
  });
  
  describe("#$window", function() {
    it("should return $(window)", function() {
      expect(view.$window()).toEqual($(window));
    });
  });  
  
  describe("#isLoaderVisible", function() {
    describe("when loader is in visible portion of window", function() {
      beforeEach(function() {
        var w = {
          scrollTop: function(){
            return 1;
          },
          height: function(){
            return 1;
          }
        };
        spyOn(view.$loaderDiv, "offset").andReturn({top: 1});
        spyOn(view, "$window").andReturn(w);
      });
      it("should return true", function() {
        expect(view.isLoaderVisible()).toEqual(true);
      });
    });

    describe("when loader is not in visible portion of window", function() {
      beforeEach(function() {
        var w = {
          scrollTop: function(){
            return 1;
          },
          height: function(){
            return 0;
          }
        };
        spyOn(view.$loaderDiv, "offset").andReturn({top: 1});
        spyOn(view, "$window").andReturn(w);
      });
      it("should return false", function() {
        expect(view.isLoaderVisible()).toEqual(false);
      });
    });
  });  
  
  describe("#activate", function() {
    it("should assing loader", function() {
      expect(view.$loader).toEqual(jasmine.any(Object));
    });
    
    it("should assing results", function() {
      expect(view.$results).toEqual(jasmine.any(Object));
    });
    
    it("should assign default filters", function() {
      expect(view.filter).toEqual({
        recommended: true,
        not_expired: true,
        page: 0
      });
    });
  });

  describe("#fetchPage", function() {
    beforeEach(function() {
      spyOn(view.$loader, "show");
      view.fetchPage();
    });

    it("should show loader", function() {
      expect(view.$loader.show).wasCalled();
    });
  });

  describe("#onSuccess", function() {
    beforeEach(function() {
      spyOn(view.$results, "append");
      spyOn(view.$loader, "hide");
      
      view.onSuccess('test data');
    });

    it("should append data to $results", function() {
      expect(view.$results.append).wasCalledWith('test data');
    });
    
    it("should show loader", function() {
      expect(view.$loader.hide).wasCalled();
    });
  });  

  describe("onScroll", function() {
    beforeEach(function() {
      view.onScroll();
    });
    
    it("call fetchPage if $loader is inside the visible window", function() {
      
    });
    
    it("should not call fetchPage if $loader is outside the visible window", function() {
      
    });
    
  });  
  
});  

