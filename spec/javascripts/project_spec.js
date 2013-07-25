describe("Project", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project({el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
  });

  describe("#toggleWarning", function() {
    beforeEach(function() {
      spyOn(view.$warning, "slideToggle");
      view.toggleWarning();
    });

    it("should call slideToggle", function() {
      expect(view.$warning.slideToggle).wasCalled();
    });
  });

  describe("#loadEmbed", function() {
    beforeEach(function(){
      spyOn(view.$embed, "data").andReturn('path');
      spyOn($, "get").andReturn({
        success: function(callback) {
          callback('HTML');
        }
      });
    });

    it("should call $.get when .loader is present", function(){
      spyOn(view.$embed, 'find').andReturn([1]);
      spyOn(view.$embed, 'html');

      view.loadEmbed();

      expect($.get).wasCalledWith('path');
      expect(view.$embed.html).wasCalledWith('HTML');
    });

    it("should not call $.get when .loader is not present", function(){
      spyOn(view.$embed, 'find').andReturn([]);

      view.loadEmbed();

      expect($.get).wasNotCalled();
    });
  });

  describe("#toggleEmbed", function() {
    beforeEach(function() {
      spyOn(view.$embed, "slideToggle");
      spyOn(view, "loadEmbed");
      view.toggleEmbed();
    });

    it("should call slideToggle", function() {
      expect(view.$embed.slideToggle).wasCalled();
    });

    it("should call loadEmbed", function() {
      expect(view.loadEmbed).wasCalled();
    });
  });

  describe("#selectTab", function() {
    var $tab = { addClass: function(){}, siblings: function(){} };
    var $sibling = { removeClass: function(){} };
    var eventTriggered = false;

    beforeEach(function() {
      spyOn($tab, "addClass");
      spyOn($tab, "siblings").andReturn($sibling);
      spyOn($sibling, "removeClass");
      view.on('onSelectTab', function(){
        eventTriggered = true;
      });
      view.selectTab($tab);
    });
    
    it("should trigger onSelectTab event", function() {
      expect(eventTriggered).toEqual(true);
    });

    it("should remove selected class from siblings", function() {
      expect($tab.siblings).wasCalledWith('.selected');
      expect($sibling.removeClass).wasCalledWith('selected');
      
    });

    it("should add selected class", function() {
      expect($tab.addClass).wasCalledWith('selected');
    });
  });  
  
  describe("toggleTab", function() {
    var $tab = { show: function(){}, siblings: function(){} };
    var $otherTabs = { hide: function(){} };
    beforeEach(function() {
      spyOn($tab, "show");
      spyOn($otherTabs, "hide");
      spyOn($tab, "siblings").andReturn($otherTabs);
      view.toggleTab($tab);
    });

    it("should show tab", function() {
      expect($tab.show).wasCalled();
    });

    it("should hide other tabs", function() {
      expect($otherTabs.hide).wasCalled();
    });
  });  
  
  describe("#onTabClick", function() {
    var $target = $('<a data-target="#selector">');
    var $tab = $('<div>');
    beforeEach(function() {
      spyOn(view, "loadTab");
      spyOn(view, "selectTab");
      spyOn(view, "$").andReturn($tab);
      spyOn(view, "toggleTab");
      view.onTabClick({target: $target});
    });

    it("should call selectTab", function() {
      expect(view.selectTab).wasCalledWith($target);
    });

    it("should call toggleTab", function() {
      expect(view.toggleTab).wasCalledWith($tab);
    });
    
    it("should call loadTab passing the obj from selector", function() {
      expect(view.$).wasCalledWith('#selector');
      expect(view.loadTab).wasCalledWith($tab);
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
        view.loadTab(tab);
      });

      it("should fill tab with data", function() {
        expect(tab.html).wasCalledWith('qux');
      });

      it("should get content", function() {
        expect($.get).wasCalledWith('/bar');
      });
    });

    describe("when tab is empty but does not have a path", function() {
      var tab = {html: function(){ return '' }, data: function(){ return undefined; }};

      beforeEach(function() {
        view.loadTab(tab);
      });

      it("should not get content", function() {
        expect($.get).wasNotCalled();
      });
    });

    describe("when tab has content", function() {
      beforeEach(function() {
        view.loadTab(view.$('#tab'));
      });

      it("should not get content", function() {
        expect($.get).wasNotCalled();
      });
    });  
    
    
    
  });  
});
