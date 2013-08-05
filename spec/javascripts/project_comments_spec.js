describe("ProjectComments", function() {
  var view, FB;
  var parentView = { on: function() {} };

  beforeEach(function() {
    FB = {
      XFBML: {
        parse: function(){}
      }
    };
    window.FB = FB;
    spyOn(parentView, "on");
    view = new App.views.Project.views.ProjectComments({parent: parentView, el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
  });

  describe("#activate", function(){
    it("should bind render to parent's onSelectTab", function() {
      expect(parentView.on).wasCalledWith('selectTab', view.render);
    });
  });

  describe("#render", function() {
    beforeEach(function(){
      spyOn(FB.XFBML, "parse");
    });

    describe("when $el is not visible", function(){
      beforeEach(function(){
        spyOn(view.$el, "is").andReturn(false);
        view.render();
      });

      it("should test $el visibility", function() {
        expect(view.$el.is).wasCalledWith(':visible');
      });

      it("should not add div.fb-comments to DOM", function() {
        expect(view.$('div.fb-comments').length).toEqual(0);
      });

      it("should not call FB.XFBML.parse", function() {
        expect(FB.XFBML.parse).wasNotCalled();
      });
    });

    describe("when $el is visible", function(){
      beforeEach(function(){
        spyOn(view.$el, "is").andReturn(true);
        view.render();
      });

      it("should test $el visibility", function() {
        expect(view.$el.is).wasCalledWith(':visible');
      });

      it("should add div.fb-comments to DOM", function() {
        expect(view.$('div.fb-comments').length).toEqual(1);
      });

      it("should call FB.XFBML.parse", function() {
        expect(FB.XFBML.parse).wasCalled();
      });
    });

  });  
});
