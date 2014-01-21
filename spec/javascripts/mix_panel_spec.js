describe("MixPanel", function() {
  var view;
  var mixpanel;

  beforeEach(function(){
    view = new App.views.MixPanel();
    window.mixpanel = mixpanel = {
      name_tag: function(){},
      identify: function(){},
      track: function(){}
    };
    spyOn(mixpanel, "name_tag");
    spyOn(mixpanel, "identify");
    spyOn(mixpanel, "track");
  });

  describe("#identifyUser", function() {
    var user = {id: 1, name: "Foo Bar"};

    beforeEach(function() {
      var $el = Backbone.$('<body></body>');
      $el.data('user', user);
      view.setElement($el, false);
      view.identifyUser();
    });

    it("should set user", function() {
      expect(view.user).toEqual(user);
    });

    it("should give a mixpanel nametag to user", function() {
      expect(mixpanel.name_tag).wasCalledWith(user.id + '-' + user.name);
    });

    it("should indentify user", function() {
      expect(mixpanel.identify).wasCalledWith(user.id);
    });
  });

  describe("#trackOnMixPanel", function() {
    var on = jasmine.createSpy().andCallFake(function(event, callback){
      callback();
    });
    var target = '#rewards .clickable';
    var event = 'click';
    var default_options = {
      'page name':  document.title,
      'user_id':    null,
      'project':    null,
      'url':        window.location
    };
    var text = 'Clicked on a reward';

    beforeEach(function() {
      spyOn(view, "$").andReturn({on: on});
      spyOn(view, "identifyUser");
      view.trackOnMixPanel(target, event, text);
    });

    it("should attach callback to event on target", function() {
      expect(view.$).wasCalledWith(target);
      expect(on).wasCalledWith(event, jasmine.any(Function));
    });

    it("should identify user in the callback", function() {
      expect(view.identifyUser).wasCalled();
    });

    it("should call track with default options", function() {
      expect(mixpanel.track).wasCalledWith(text, default_options);
    });
  });

  describe("#activate", function() {
    beforeEach(function() {
      spyOn(view, "trackUserClickOnProjectsImage");
      spyOn(view, "trackUserClickOnProjectsTitle");
      spyOn(view, "trackUserClickOnContributeButton");
      spyOn(view, "trackUserClickOnReviewAndMakePayment");
      spyOn(view, "trackUserClickOnAcceptTerms");
      spyOn(view, "trackUserClickOnPaymentButton");
      spyOn(view, "trackUserClickOnReward");
      view.activate();
    });

    it("should call all track methods", function() {
      expect(view.trackUserClickOnProjectsImage).wasCalled();
      expect(view.trackUserClickOnProjectsTitle).wasCalled();
      expect(view.trackUserClickOnContributeButton).wasCalled();
      expect(view.trackUserClickOnReviewAndMakePayment).wasCalled();
      expect(view.trackUserClickOnAcceptTerms).wasCalled();
      expect(view.trackUserClickOnPaymentButton).wasCalled();
      expect(view.trackUserClickOnReward).wasCalled();
    });

  });

});

