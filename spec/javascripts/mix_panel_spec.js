describe("MixPanel", function() {
  var view;
  var mixpanel;
  var default_options = {
    'page name':  document.title,
    'user_id':    null,
    'project':    null,
    'url':        window.location
  };

  beforeEach(function(){
    view = new App.views.MixPanel();
    view.controller = "testController";
    view.action = "testAction";
    window.mixpanel = mixpanel = {
      name_tag: function(){},
      identify: function(){},
      track: function(){},
      people: {
        set: function(){}
      }
    };
    spyOn(mixpanel, "name_tag");
    spyOn(mixpanel, "identify");
    spyOn(mixpanel, "track");
    spyOn(mixpanel.people, "set");
  });

  describe("#trackPageLoad", function(){
    var text = 'Foo Bar';

    beforeEach(function() {
      spyOn(view, "track");
    });

    it("should not call trackVisit when controller and action do not match arguments", function(){
      view.trackPageLoad(view.controller, 'bar', text);
      expect(view.track).not.toHaveBeenCalled();
    });

    it("should call trackVisit when controller and action match arguments", function(){
      view.trackPageLoad(view.controller, view.action, text);
      expect(view.track).toHaveBeenCalledWith(text);
    });
  });

  describe("#trackPageVisit", function(){
    var text = 'Foo Bar';

    beforeEach(function() {
      spyOn(view, "trackVisit");
    });

    it("should not call trackVisit when controller and action do not match arguments", function(){
      view.trackPageVisit(view.controller, 'bar', text);
      expect(view.trackVisit).not.toHaveBeenCalled();
    });

    it("should call trackVisit when controller and action match arguments", function(){
      view.trackPageVisit(view.controller, view.action, text);
      expect(view.trackVisit).toHaveBeenCalledWith(text);
    });
  });

  describe("#trackVisit", function(){
    var text = 'Foo Bar';

    beforeEach(function() {
      spyOn(window, "setTimeout").and.callFake(function(callback){ callback(); });;
      spyOn(view, "track");
      view.trackVisit(text);
    });

    it("should call mixpanel.track in timeout callback", function(){
      expect(window.setTimeout).toHaveBeenCalledWith(jasmine.any(Function), view.VISIT_MIN_TIME);
      expect(view.track).toHaveBeenCalledWith(text);
    });
  });

  describe("#track", function(){
    var text = 'Foo Bar';

    beforeEach(function() {
      view.track(text);
    });

    it("should call mixpanel.track", function(){
      expect(mixpanel.track).toHaveBeenCalledWith(text, default_options);
    });
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
      expect(mixpanel.name_tag).toHaveBeenCalledWith(user.email);
    });

    it("should indentify user", function() {
      expect(mixpanel.identify).toHaveBeenCalledWith(user.id);
    });
  });

  describe("#trackOnPage", function(){
    var callback = jasmine.createSpy().and.returnValue();
    beforeEach(function() {
    });

    it("should not call callback if controller and action match parameters", function() {
      view.trackOnPage('foo', 'bar', callback);
      expect(callback).not.toHaveBeenCalled();
    });

    it("should call callback if controller and action match parameters", function() {
      view.trackOnPage(view.controller, view.action, callback);
      expect(callback).toHaveBeenCalled();
    });
  });

  describe("#mixPanelEvent", function() {
    var on = jasmine.createSpy().and.callFake(function(event, callback){
      callback();
    });
    var target = '#rewards .clickable';
    var event = 'click';
    var text = 'Clicked on a reward';

    beforeEach(function() {
      spyOn(view, "$").and.returnValue({on: on});
      spyOn(view, "identifyUser");
      view.mixPanelEvent(target, event, text);
    });

    it("should attach callback to event on target", function() {
      expect(view.$).toHaveBeenCalledWith(target);
      expect(on).toHaveBeenCalledWith(event, jasmine.any(Function));
    });

    it("should identify user in the callback", function() {
      expect(view.identifyUser).toHaveBeenCalled();
    });

    it("should call track with default options", function() {
      expect(mixpanel.track).toHaveBeenCalledWith(text, default_options);
    });
  });
});

