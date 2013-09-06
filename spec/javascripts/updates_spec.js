describe("Updates", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.Updates({ parent: { on: function(){} } });
    app = new App();
  });

  describe("#onUpdateCreate", function() {
    beforeEach(function() {
      spyOn(view.$results, "prepend");
      spyOn(app, "flash");
      view.onUpdateCreate(null, 'test');
    });

    it("should prepend data", function() {
      expect(view.$results.prepend).wasCalledWith('test');
    });

    it("should display flash", function() {
      expect(app.flash.wasCalled();
    });
  });

  describe("#onUpdateDestroy", function() {
    var $target;
    var $count;
    beforeEach(function() {
      view.parent = { $: function(){} };
      $target = $('<div class="update">');
      $count = $('<div class="count">');
      spyOn(window, "$").andReturn($target);
      spyOn($target, "remove");
      spyOn(view.parent, "$").andReturn($count);
      spyOn($count, "html");

      view.onUpdateDestroy({currentTarget: $target});
    });

    it("should get currentTarget and remove it", function() {
      expect(window.$).wasCalledWith($target);
      expect($target.remove).wasCalled();
    });

     it("should update count", function() {
       expect($count.html).wasCalledWith(' (0)');
     });
  });
});
