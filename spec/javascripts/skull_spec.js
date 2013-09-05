describe("Skull.View", function(){
  var ViewClass, view, parent, root;

  beforeEach(function(){
    root = { router: { route: function(){} } };
    parent = { parent: root };
    ViewClass = Skull.View.extend({ parent: parent, el: 'test' });
    view = new ViewClass();
  });
  
  describe(".addChild", function() {
    beforeEach(function() {
      ViewClass.addChild('NewChild', {el: 'test'}, {});
    });

    it("should assign new class to parent views object", function() {
      expect(ViewClass.views.NewChild).toEqual(jasmine.any(Function));
    });
    
    it("should assign el to view class", function() {
      expect(ViewClass.views.NewChild.el).toEqual('test');
    });

    it("should initialize views object as empy in new class", function() {
      expect(ViewClass.views.NewChild.views).toEqual({});
    });
  });  
  
  describe(".extend", function() {
    it("should have object views in constructor", function() {
      expect(ViewClass.views).toEqual(jasmine.any(Object));
    });
  });

  describe("#addView", function() {
    var ChildClass;

    beforeEach(function() {
      ChildClass = Skull.View.extend({ el: 'child' });
      view.addView('childClass', ChildClass);
    });
    
    it("should add instance of view object to the view if it is not there", function() {
      expect(view._childClass).toEqual(jasmine.any(ChildClass));
    });

    it("should not create new instance if it's already in there", function() {
      var AnotherClass = jasmine.createSpy('AnotherClass');
      view.addView('childClass', AnotherClass);
      expect(AnotherClass).wasNotCalled();
      expect(view._childClass).toEqual(jasmine.any(ChildClass));
    });
  });  
  
  describe("#rootView", function() {
    it("should return root view", function() {
      expect(view.rootView()).toEqual(root);
    });
  });  

  describe("#router", function() {
    it("should return rootView router", function() {
      view.router();
      expect(view.router()).toEqual(view.rootView().router);
    });
  });  
  
  describe("#route", function() {
    var routeName = 'route_name';
    beforeEach(function() {
      spyOn(view.router(), "route");
      view.route(routeName);
    });

    it("should create route in rootView router", function() {
      expect(view.router().route).wasCalledWith(routeName, routeName.split("/")[0], jasmine.any(Function));
    });
  });
  
  describe("#createViewGetters", function() {
    beforeEach(function() {
      ViewClass.addChild('ChildClass', { el: '.child' });
      ViewClass.addChild('AnotherChildClass', { el: '.another-child' });
      spyOn(view, "addView");
      var $el = Backbone.$('<div><div class="child"></div></div>');
      view.setElement($el, false);
      view.createViewGetters();
    });

    it("should not call the getter if the child el is present in parent's DOM", function() {
      expect(view.addView).wasNotCalledWith('anotherChildClass', ViewClass.views.AnotherChildClass);
    });

    it("should call the getter if the child el is present in parent's DOM", function() {
      expect(view.addView).wasCalledWith('childClass', ViewClass.views.ChildClass);
    });
    
    it("should define a getter that calls addView with keys and values of views object", function() {
      view.anotherChildClass; 
      expect(view.addView).wasCalledWith('anotherChildClass', ViewClass.views.AnotherChildClass);
    });
  });  
});
