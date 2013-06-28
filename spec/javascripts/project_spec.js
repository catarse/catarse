describe("Project", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project({el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
  });

  describe("#selectTab", function() {
    var $tab = { addClass: function(){} };

    beforeEach(function() {
      spyOn($tab, "addClass");
      view.selectTab($tab);
    });
    
    it("should add selected class", function() {
      
    });
    
  });  
  
  describe("#onTabClick", function() {
    var $target = $('<a data-target="#selector">');
    beforeEach(function() {
      spyOn(view, "loadTab");
      spyOn(view, "selectTab");
      view.onTabClick({target: $target});
    });

    it("should call selectTab", function() {
      expect(view.selectTab).wasCalledWith($target);
    });

    it("should call loadTab passing the selector", function() {
      expect(view.loadTab).wasCalledWith('#selector');
    });
  });  
  
  describe("#loadTab", function() {
    beforeEach(function() {
      spyOn($, "get").andReturn({success: function(callback){ callback('qux'); } });
    });

    describe("when tab is empty", function() {
      var tab = {html: function(){ return '' }, data: function(){ return '/bar' }};

      beforeEach(function() {
        spyOn(tab, "html");
        spyOn(view, "$").andReturn(tab);
        view.loadTab('#emptyTab');
      });

      it("should fill tab with data", function() {
        expect(tab.html).wasCalledWith('qux');
      });

      it("should get content", function() {
        expect($.get).wasCalledWith('/bar');
      });
    });

    describe("when tab has content", function() {
      beforeEach(function() {
        view.loadTab('#tab');
      });

      it("should not get content", function() {
        expect($.get).wasNotCalled();
      });
    });  
    
    
    
  });  
});
