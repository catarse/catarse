RSpec.describe("Explore", function() {
  var view;
  var parentView = { $search: { val: function(){} }, router: {route: function(){} } };

  beforeEach(function() {
    view = new App.views.Explore({ parent: parentView });
  });
  
  describe("#$window", function() {
    it("should return $(window)", function() {
      expect(view.$window()).toEqual($(window));
    });
  });  
  
  describe("#isLoaderDivVisible", function() {
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
        spyOn(view.$loaderDiv, "is").and.returnValue(true);
        spyOn(view.$loaderDiv, "offset").and.returnValue({top: 1});
        spyOn(view, "$window").and.returnValue(w);
      });
      it("should return true", function() {
        expect(view.isLoaderDivVisible()).toEqual(true);
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
        spyOn(view.$loaderDiv, "offset").and.returnValue({top: 1});
        spyOn(view, "$window").and.returnValue(w);
      });
      it("should return false", function() {
        expect(view.isLoaderDivVisible()).toEqual(false);
      });
    });
  });  
  
  describe("#setInitialFilter", function() {
    describe("when parent has search set", function() {
      it("set filter for search", function() {
        view.parent = { $search: $('<input type="text" value="foo">') };
        view.setInitialFilter();
        expect(view.filter).toEqual({
          pg_search: 'foo'
        });
      });
    });  

    describe("when parent does not have search set", function() {
      it("should assign default filters", function() {
        view.setInitialFilter();
        expect(view.filter).toEqual({
          recommended: true,
          not_expired: true
        });
      });
    });  
  });  
  
  describe("#activate", function() {
    it("should assing loader", function() {
      expect(view.$loader).toEqual(jasmine.any(Object));
    });
    
    it("should assing false to EOF results", function() {
      expect(view.EOF).toEqual(false);
    });

    it("should assing results", function() {
      expect(view.$results).toEqual(jasmine.any(Object));
    });
    
    it("should call setInitialFilter", function() {
      spyOn(view, "setInitialFilter");
      view.activate();
      expect(view.setInitialFilter).toHaveBeenCalled();
    });
  });

  describe("#followRoute", function() {
    var el;

    beforeEach(function() {
      spyOn(view, "firstPage");
      spyOn(view, "fetchPage");
      spyOn(view, "selectLink");
      view.followRoute('recent', 'recent', []);
    });

    it("should assign filter to view", function() {
      expect(view.filter).toEqual({recent: true});
    });

    it("should call firstPage", function() {
      expect(view.firstPage).toHaveBeenCalled();
    });

    it("should call fetchPage", function() {
      expect(view.fetchPage).toHaveBeenCalled();
    });

    it("should call selectLink", function() {
      expect(view.selectLink).toHaveBeenCalled();
    });
  });

  describe("#firstPage", function() {
    beforeEach(function() {
      view.EOF = true;
      view.filter.page = 2;
      spyOn(view, "fetchPage");
      spyOn(view.$results, "html");
      view.firstPage();
    });

    it("should assign false to EOF", function() {
      expect(view.EOF).toEqual(false);
    });

    it("should clear results", function() {
      expect(view.$results.html).toHaveBeenCalledWith('');
    });

    it("assign 1 to filter.page", function() {
      expect(view.filter.page).toEqual(1);
    });
  });  
  
  describe("#fetchPage", function() {
    describe("when EOF is true and isLoaderDivVisible is true", function(){
      beforeEach(function() {
        view.EOF = true;
        spyOn(view, "isLoaderDivVisible").and.returnValue(false);
        spyOn(view.$loader, "show");
        view.fetchPage();
      });

      it("should not increment page", function() {
        expect(view.filter.page).toEqual(1);
      });

      it("should not show loader", function() {
        expect(view.$loader.show).not.toHaveBeenCalled();
      });
    });

    describe("when EOF is false", function(){
      beforeEach(function() {
        view.EOF = false;
        spyOn(view, "isLoaderDivVisible").and.returnValue(true);
        spyOn(view.$loader, "show");
        view.fetchPage();
      });

      it("should increment page", function() {
        expect(view.filter.page).toEqual(2);
      });

      it("should show loader", function() {
        expect(view.$loader.show).toHaveBeenCalled();
      });
    });
  });

  describe("#onSuccess", function() {
    beforeEach(function() {
      spyOn(view.$results, "append");
      spyOn(view.$loader, "hide");
      
      view.onSuccess('test data');
    });

    it("should append data to $results", function() {
      expect(view.$results.append).toHaveBeenCalledWith('test data');
    });
    
    it("should show loader", function() {
      expect(view.$loader.hide).toHaveBeenCalled();
    });
  });  

  describe("onScroll", function() {
    beforeEach(function() {
      spyOn(view, "fetchPage");
      view.onScroll();
    });
    
    it("call fetchPage", function() {
      expect(view.fetchPage).toHaveBeenCalled();
    });
    
  });  
  
});  

