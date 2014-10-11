RSpec.describe("Project", function() {
  var view;
  var parentView = { router: {route: function(){} } };

  beforeEach(function() {
    view = new App.views.Project({ parent: parentView, el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
  });

  describe("#toggleWarning", function() {
    beforeEach(function() {
      spyOn(view.$warning, "slideToggle");
      view.toggleWarning();
    });

    it("should call slideToggle", function() {
      expect(view.$warning.slideToggle).toHaveBeenCalled();
    });
  });

  describe("#loadEmbed", function() {
    beforeEach(function(){
      spyOn(view.$embed, "data").and.returnValue('path');
      spyOn($, "get").and.returnValue({
        success: function(callback) {
          callback('HTML');
        }
      });
    });

    it("should call $.get when .loader is present", function(){
      spyOn(view.$embed, 'find').and.returnValue([1]);
      spyOn(view.$embed, 'html');

      view.loadEmbed();

      expect($.get).toHaveBeenCalledWith('path');
      expect(view.$embed.html).toHaveBeenCalledWith('HTML');
    });

    it("should not call $.get when .loader is not present", function(){
      spyOn(view.$embed, 'find').and.returnValue([]);

      view.loadEmbed();

      expect($.get).not.toHaveBeenCalled();
    });
  });

  describe("#toggleEmbed", function() {
    beforeEach(function() {
      spyOn(view.$embed, "slideToggle");
      spyOn(view, "loadEmbed");
      view.toggleEmbed();
    });

    it("should call slideToggle", function() {
      expect(view.$embed.slideToggle).toHaveBeenCalled();
    });

    it("should call loadEmbed", function() {
      expect(view.loadEmbed).toHaveBeenCalled();
    });
  });

  describe("#selectTab", function() {
    var $tab = { addClass: function(){}, siblings: function(){}, data: function(){} };
    var $tabContent = { show: function(){}, siblings: function(){} };
    var $tabSiblings = { removeClass: function(){} };
    var $tabContentSiblings = { hide: function(){} };
    var eventTriggered = false;

    beforeEach(function() {
      spyOn($tab, "addClass");
      spyOn($tabContent, "show");
      spyOn($tab, "siblings").and.returnValue($tabSiblings);
      spyOn($tabContent, "siblings").and.returnValue($tabContentSiblings);
      spyOn($tabSiblings, "removeClass");
      spyOn($tabContentSiblings, "hide");
      spyOn(view, "$").and.returnValue($tabContent);
      view.on('selectTab', function(){
        eventTriggered = true;
      });
      view.selectTab($tab, $tabContent);
    });
    
    it("should trigger onSelectTab event", function() {
      expect(eventTriggered).toEqual(true);
    });

    it("should remove selected class from siblings", function() {
      expect($tab.siblings).toHaveBeenCalledWith('.selected');
      expect($tabSiblings.removeClass).toHaveBeenCalledWith('selected');
    });

    it("should add selected class", function() {
      expect($tab.addClass).toHaveBeenCalledWith('selected');
    });

    it("should show tab content", function() {
      expect($tabContent.show).toHaveBeenCalled();
    });

    it("should hide other tab contents", function() {
      expect($tabContentSiblings.hide).toHaveBeenCalled();
    });
  });  
  
  describe("#onTabClick", function() {
    var $target = $('<a data-target="#selector">');
    var $tab = $('<div>');
    beforeEach(function() {
      spyOn(view, "loadTab");
      spyOn(view, "selectTab");
      spyOn(view, "$").and.returnValue($tab);
      view.onTabClick({currentTarget: $target});
    });

    it("should call selectTab", function() {
      expect(view.selectTab).toHaveBeenCalledWith($($target), $tab);
    });

    it("should call loadTab passing the obj from selector", function() {
      expect(view.$).toHaveBeenCalledWith('#selector');
      expect(view.loadTab).toHaveBeenCalledWith($tab);
    });
  });  
  
  describe("#loadTab", function() {
    beforeEach(function() {
      spyOn($, "get").and.returnValue({success: function(callback){ callback('qux'); } });
    });

    describe("when tab is empty", function() {
      var tab = {html: function(){ return '' }, data: function(){ return '/bar' }};

      beforeEach(function() {
        spyOn(tab, "html");
        view.loadTab(tab);
      });

      it("should fill tab with data", function() {
        expect(tab.html).toHaveBeenCalledWith('qux');
      });

      it("should get content", function() {
        expect($.get).toHaveBeenCalledWith('/bar');
      });
    });

    describe("when tab is empty but does not have a path", function() {
      var tab = {html: function(){ return '' }, data: function(){ return undefined; }};

      beforeEach(function() {
        view.loadTab(tab);
      });

      it("should not get content", function() {
        expect($.get).not.toHaveBeenCalled();
      });
    });

    describe("when tab has content", function() {
      beforeEach(function() {
        view.loadTab(view.$('#tab'));
      });

      it("should not get content", function() {
        expect($.get).not.toHaveBeenCalled();
      });
    });  
    
    
    
  });  
});
