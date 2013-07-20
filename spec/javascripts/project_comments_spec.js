describe("ProjectComments", function() {
  var view, parentView, FB;

  beforeEach(function() {
    FB = {
      XFBML: {
        parse: function(){}
      }
    };
    window.FB = FB;
    parentView = new App.views.Project({el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
    spyOn(parentView, "on");
    view = new App.views.Project.views.ProjectComments({parent: parentView, el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
  });

  describe("#activate", function(){
    it("should bind render to parent's onSelectTab", function() {
      expect(parentView.on).wasCalledWith('onSelectTab', view.render);
    });
  });

  describe("#render", function() {
    beforeEach(function(){
      spyOn(FB.XFBML, "parse");
      view.render();
    });

    it("should add div.fb-comments to DOM", function() {
      expect(view.$('div.fb-comments').length).toEqual(1);
    });
    
    it("should call FB.XFBML.parse", function() {
      expect(FB.XFBML.parse).wasCalled();
    });
  });  
});
