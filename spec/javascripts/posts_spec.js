describe("Updates", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.Updates({ parent: { on: function(){} } });
    app = {
      flash: function(){}
    };
  });

  describe("#onUpdateCreate", function() {
    beforeEach(function() {
      spyOn(view.$results, "prepend");
      spyOn(app, "flash");
      view.onUpdateCreate(null, 'test');
    });

    it("should prepend data", function() {
      expect(view.$results.prepend).toHaveBeenCalledWith('test');
    });

    it("should display flash", function() {
      expect(app.flash).toHaveBeenCalled();
    });
  });

  describe("#onUpdateDestroy", function() {
    var $target;
    var $count;
    beforeEach(function() {
      view.parent = { $: function(){} };
      $target = $('<div class="update">');
      $count = $('<div class="count">');
      spyOn(window, "$").and.returnValue($target);
      spyOn($target, "remove");
      spyOn(view.parent, "$").and.returnValue($count);
      spyOn($count, "html");

      view.onUpdateDestroy({currentTarget: $target});
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
