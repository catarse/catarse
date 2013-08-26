describe("FeedbackSupport", function() {
  var view;

  beforeEach(function() {
    view = new App.views.FeedbackSupport({el: $('<div></div>')});
  });

  describe("#openFeedbackSupport", function(){
    beforeEach(function(){
      spyOn(view.$feedbackSupportClosed, 'fadeOut');
      spyOn(view.$feedbackSupportOpened, 'fadeIn');

      view.openFeedbackSupport();
    });

    it("should call fadeIn on feedback opened", function() {
      expect(view.$feedbackSupportOpened.fadeIn).wasCalled();
    });

    it("should call fadeOut on feedback closed", function() {
      expect(view.$feedbackSupportClosed.fadeOut).wasCalled();
    });
  });

  describe("#closeFeedbackSupport", function(){
    beforeEach(function(){
      spyOn(view.$feedbackSupportClosed, 'fadeIn');
      spyOn(view.$feedbackSupportOpened, 'fadeOut');

      view.closeFeedbackSupport();
    });

    it("should call fadeOut on feedback opened", function() {
      expect(view.$feedbackSupportOpened.fadeOut).wasCalled();
    });

    it("should call fadeIn on feedback closed", function() {
      expect(view.$feedbackSupportClosed.fadeIn).wasCalled();
    });
  });
});
