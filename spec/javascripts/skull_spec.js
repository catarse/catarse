describe("Skull.View", function(){
  var ViewClass;
  var view;

  beforeEach(function(){
    ViewClass = Skull.View.extend({ el: 'test' });
    view = new ViewClass();
  });

  
  describe(".extend", function() {
    it("should assign el element to ViewClass constructor", function() {
      expect(ViewClass.el).toEqual('test');
    });

    it("should have object views in constructor", function() {
      expect(ViewClass.views).toEqual({});
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
  
  describe("#createViewGetters", function() {
    beforeEach(function() {
      view.constructor.views = { 
        ChildClass: Skull.View.extend({ el: '.child' }),
        AnotherChildClass: Skull.View.extend({ el: '.another-child' })
      };
      spyOn(view, "addView");
      var $el = Backbone.$('<div><div class="child"></div></div>');
      view.setElement($el, false);
      view.createViewGetters();
    });

    it("should not call the getter if the child el is present in parent's DOM", function() {
      expect(view.addView).wasNotCalledWith('anotherChildClass', view.constructor.views.AnotherChildClass);
    });

    it("should call the getter if the child el is present in parent's DOM", function() {
      expect(view.addView).wasCalledWith('childClass', view.constructor.views.ChildClass);
    });
    
    it("should define a getter that calls addView with keys and values of views object", function() {
      view.anotherChildClass; 
      expect(view.addView).wasCalledWith('anotherChildClass', view.constructor.views.AnotherChildClass);
    });
  });  
});
