describe("App", function() {
  var view;

  beforeEach(function() {
    $.fn.best_in_place = function(){};
    spyOn(Backbone.history, "start");
    view = new App();
  });

  describe("#maskElement", function() {
    var element = $('<input data-mask="999" />');
    beforeEach(function() {
      spyOn(view, "$").andReturn(element);
      spyOn(element, "mask");
      view.maskElement(1, element);
    });

    it("should call mask using data from DOM element of parameter", function() {
      expect(element.mask).wasCalledWith('999');
    });
  });

  describe("#checkBadBrowser", function(){
    beforeEach(function() {
      view.$el.data('badbrowser-path', 'test-path');
      spyOn(view, "navigate");
      
    });
    
    describe("when browserHasCheckValidity is false", function(){
      beforeEach(function() {
        spyOn(view, "browserHasCheckValidity").andReturn(false);
        view.checkBadBrowser();
      });

      it("should navigate to root el badbrowser-path", function() {
        expect(view.navigate).wasCalledWith('test-path');
      });
    });
    describe("when browserHasCheckValidity is true", function(){
      beforeEach(function() {
        spyOn(view, "browserHasCheckValidity").andReturn(true);
        view.checkBadBrowser();
      });

      it("should not navigate to root el badbrowser-path", function() {
        expect(view.navigate).wasNotCalled();
      });
    });
  });

  describe("#browserHasCheckValidity", function(){
    describe("when input element checkValidity is undefined", function(){
      var element = $('<input data-mask="999" />');
      beforeEach(function() {
        element[0].checkValidity = undefined;
        spyOn(window, "$").andReturn(element);
      });
      it("should return false", function() {
        expect(view.browserHasCheckValidity()).toEqual(false);
      });
    });
    describe("when input element implements checkValidity", function(){
      it("should return true", function() {
        expect(view.browserHasCheckValidity()).toEqual(true);
      });
    });
  });

  describe("#activate", function() {
    var best_in_place = { best_in_place: function(){}, each: function(callback){ callback(0, 'el'); } };
    beforeEach(function() {
      spyOn(best_in_place, "best_in_place");
      spyOn(view, "$").andReturn(best_in_place);
      spyOn(view, "maskElement");

      view.activate();
    });

    it("should iterate over inputs with data-mask and call maskElement", function() {
      expect(view.$).wasCalledWith('input[data-mask]');
      expect(view.maskElement).wasCalledWith(0, 'el');
    });


    it("should call best_in_place for every .best_in_place class", function() {
      expect(view.$).wasCalledWith('.best_in_place');
      expect(best_in_place.best_in_place).wasCalled();
    });

    it("should assign $dropdown", function() {
      expect(view.$dropdown).toEqual(jasmine.any(Object));
    });
  });

  describe("#flash", function() {
    var flash = { slideDown: function(){}, slideUp: function(){}};

    beforeEach(function() {
      spyOn(window, "setTimeout").andCallFake(function(callback, timeout){ callback(); });
      spyOn(view, '$').andReturn(flash);
      spyOn(flash, "slideDown");
      spyOn(flash, "slideUp");
      view.flash();
    });

    it("should call setTimeout twice", function() {
      expect(window.setTimeout.calls.length).toEqual(2);
    });

    it("should call slideUp on callback", function() {
      expect(view.$flash.slideUp).wasCalledWith('slow');
    });

    it("should call slideDown on callback", function() {
      expect(view.$flash.slideDown).wasCalledWith('slow');
    });
  });

  describe("#toggleMenu", function() {
    beforeEach(function() {
      spyOn(view.$dropdown, "slideToggle");
      view.toggleMenu();
    });

    it("should call slideToggle on $dropdown", function() {
      expect(view.$dropdown.slideToggle).wasCalled();
    });
  });

});

