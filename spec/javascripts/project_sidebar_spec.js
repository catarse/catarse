describe("ProjectSidebar", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.ProjectSidebar({el: $('<div></div>')});
  });

  
  describe("#showNewRewardForm", function() {
    var event = {
      preventDefault: function() {},
      currentTarget: 'selector'
    };

    beforeEach(function() {
      spyOn(event, "preventDefault");
      view.showNewRewardForm(event);
    });
    
    it("should call preventDefault", function() {
       expect(event.preventDefault).wasCalled();
    });
    
    
  });  
  
});
