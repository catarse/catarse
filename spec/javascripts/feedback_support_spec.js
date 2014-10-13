RSpec.describe("FeedbackSupport", function() {
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
      expect(view.$feedbackSupportOpened.fadeIn).toHaveBeenCalled();
    });

    it("should call fadeOut on feedback closed", function() {
      expect(view.$feedbackSupportClosed.fadeOut).toHaveBeenCalled();
    });
  });

  describe("#closeFeedbackSupport", function(){
    beforeEach(function(){
      spyOn(view.$feedbackSupportClosed, 'fadeIn');
      spyOn(view.$feedbackSupportOpened, 'fadeOut');

      view.closeFeedbackSupport();
    });

    it("should call fadeOut on feedback opened", function() {
      expect(view.$feedbackSupportOpened.fadeOut).toHaveBeenCalled();
    });

    it("should call fadeIn on feedback closed", function() {
      expect(view.$feedbackSupportClosed.fadeIn).toHaveBeenCalled();
    });
  });
});
