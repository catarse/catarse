RSpec.describe("Posts", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.Posts({ parent: { on: function(){} } });
    app = {
      flash: function(){}
    };
  });

  describe("#onPostCreate", function() {
    beforeEach(function() {
      spyOn(view.$results, "prepend");
      spyOn(app, "flash");
      view.onPostCreate(null, 'test');
    });

    it("should prepend data", function() {
      expect(view.$results.prepend).toHaveBeenCalledWith('test');
    });

    it("should display flash", function() {
      expect(app.flash).toHaveBeenCalled();
    });
  });

  describe("#onPostDestroy", function() {
    var $target;
    var $count;
    beforeEach(function() {
      view.parent = { $: function(){} };
      $target = $('<div class="post">');
      $count = $('<div class="count">');
      spyOn(window, "$").and.returnValue($target);
      spyOn($target, "remove");
      spyOn(view.parent, "$").and.returnValue($count);
      spyOn($count, "html");

      view.onPostDestroy({currentTarget: $target});
    });

    it("should get currentTarget and remove it", function() {
      expect(window.$).toHaveBeenCalledWith($target);
      expect($target.remove).toHaveBeenCalled();
    });

     it("should update count", function() {
       expect($count.html).toHaveBeenCalledWith(' (0)');
     });
  });
});
