describe("MixPanel", function() {
  var view;
  var mixpanel;

  beforeEach(function(){
    view = new App.views.MixPanel();
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

  describe("#mixPanelEvent", function() {
    var on = jasmine.createSpy().and.callFake(function(event, callback){
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

