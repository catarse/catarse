describe("App", function() {
  var view;

  beforeEach(function() {
    $.fn.best_in_place = function(){};
    view = new App();
  });

  describe("#activate", function() {
    var best_in_place = { best_in_place: function(){} };
    beforeEach(function() {
      spyOn(best_in_place, "best_in_place");
      spyOn(view, "$").andReturn(best_in_place);
      view.activate();
    });

    it("should call best_in_place for every .best_in_place class", function() {
      expect(view.$).wasCalledWith('.best_in_place');
      expect(best_in_place.best_in_place).wasCalled();
    });

    it("should assign $dropdown", function() {
      expect(view.$dropdown).toEqual(jasmine.any(Object));
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

