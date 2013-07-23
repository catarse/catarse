describe("ProjectSidebar", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.ProjectSidebar({el: $('<div></div>')});
  });

  
  describe("#showNewRewardForm", function() {
    var event = {
      preventDefault: function() {},
      currentTarget: {
        data: function(){ return 'selector'; },
        fadeOut: function(){}
      }
    };
    var form = {
      fadeIn: function(){}
    };

    beforeEach(function() {
      spyOn(event, "preventDefault");
      spyOn(view, "$").andCallFake(function(el){
        return (el == 'selector' ? form : event.currentTarget);
      });
      spyOn(event.currentTarget, "fadeOut");
      spyOn(form, "fadeIn");
      view.showRewardForm(event);
    });

    it("should call fadeOut on currentTarget element", function() {
      expect(event.currentTarget.fadeOut).wasCalled();
    });

    it("should call fadeIn on data('target') of currentTarget", function() {
      expect(view.$).wasCalledWith('selector');
      expect(form.fadeIn).wasCalled();
    });
    
    it("should call preventDefault", function() {
       expect(event.preventDefault).wasCalled();
    });
  });  
  
});
