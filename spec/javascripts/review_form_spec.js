describe("ReviewForm", function() {
  var view;

  beforeEach(function() {
    view = new App.views.ReviewForm({ el: $('<form></form>')});
  });

  describe("#validate", function() {
    beforeEach(function() {
      spyOn(view.el, "checkValidity");
      view.validate();
    });

    it("should call el's check validity", function() {
      expect(view.el.checkValidity).wasCalled();
    });
  });  
});

