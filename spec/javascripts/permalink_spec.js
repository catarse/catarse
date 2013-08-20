describe("Permalink", function() {
  var view;

  beforeEach(function() {
    view = new App.views.ProjectForm.views.Permalink({ el: $('<input pattern="^(\\w|-)+$">') });
  });

  describe("checkPermalink", function() {
    var get;
    beforeEach(function() {
      get = spyOn($, "get");
    });

    describe("when pattern is matched", function() {
      beforeEach(function() {
        spyOn(view.$el, "trigger");
        get.andReturn({ complete: function(callback){ callback({ status: 200 }); } });
        view.$el.val('a');
      });

      it("should not trigger invalid if return status is 404", function() {
        get.andReturn({ complete: function(callback){ callback({ status: 404 }); } });
        view.checkPermalink();
        expect(view.$el.trigger).wasNotCalled();
      });

      it("should trigger invalid if return status is not 404", function() {
        view.checkPermalink();
        expect(view.$el.trigger).wasCalledWith('invalid');
      });
      
      it("should search for permalink", function() {
        view.checkPermalink();
        expect($.get).wasCalledWith('/pt/a');
      });
    });

    describe("when pattern is not matched", function() {
      beforeEach(function() {
        view.$el.val('wont match');
        view.checkPermalink();
      });

      it("should not search for permalink", function() {
        expect($.get).wasNotCalled();
      });
    });  
  });  
});  

