RSpec.describe("MixPanel", function() {
  var view;
  var mixpanel;
  var default_options = {
    'page name':          document.title,
    'user_id':            null,
    'created':            null,
    'last_login':         null,
    'contributions':      null,
    'has_contributions':  null,
    'project':            null,
    'url':                window.location
  };
  var user = {id: 1, name: "Foo Bar"};

  beforeEach(function(){
    view = new App.views.MixPanel();
    view.controller = "testController";
    view.action = "testAction";

    window.FB = {
      Event: {
        subscribe: function(event_name, callback) {}
      }
    };

    window.mixpanel = mixpanel = {
      name_tag: function(){},
      alias: function(){},
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

  describe('#trackOnFacebookLike', function() {
    beforeEach(function(){
      spyOn(view, 'track');

      spyOn(FB.Event, "subscribe").and.callFake(function(event, callback) {
        callback('Liked a project', {});
      });
    });

    it("should call subscribe on edge.create", function(){
      view.trackOnFacebookLike();
      expect(FB.Event.subscribe).toHaveBeenCalledWith('edge.create', jasmine.any(Function));
      expect(view.track).toHaveBeenCalledWith('Liked a project', jasmine.any(Object));
    });
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

  describe("#onLogin", function(){
    beforeEach(function() {
      spyOn(mixpanel, "alias");
      spyOn(view, "track");
    });

    describe("when user has 1 login", function(){
      beforeEach(function() {
        user.created_today = true;
        view.user = user;
        view.onLogin();
      });

      it("should alias the user in mixpanel", function(){
        expect(mixpanel.alias).toHaveBeenCalledWith(user.id);
      });

      it("should track login event", function(){
        expect(view.track).toHaveBeenCalledWith("Signed up");
      });
    });

    describe("when user has more than 1 login", function(){
      beforeEach(function() {
        user.created_today = false;
        view.user = user;
        view.onLogin();
      });

      it("should alias the user in mixpanel", function(){
        expect(mixpanel.alias).toHaveBeenCalledWith(user.id);
      });

      it("should track login event", function(){
        expect(view.track).toHaveBeenCalledWith("Logged in");
      });
    });
  });

  describe("#detectLogin", function() {
    describe("when we have an user", function(){
      beforeEach(function() {
        spyOn(view, "onLogin");
        store.set('user_id', null);
        view.user = user;
        view.detectLogin();
      });

      it("should call onLogin", function(){
        expect(view.onLogin).toHaveBeenCalled();
      });

      it("should store the user id", function(){
        expect(store.get('user_id')).toBe(user.id);
      });
    });

    describe("when we do not have an user", function(){
      beforeEach(function() {
        store.set('user_id', 1);
        view.user = null;
        view.detectLogin();
      });

      it("should store null in the user id", function(){
        expect(store.get('user_id')).toBe(null);
      });
    });
  });

  describe("#identifyUser", function() {
    beforeEach(function() {
      view.user = user;
      view.identifyUser();
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

