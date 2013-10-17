describe("HowItWorks", function() {
  var view;

  beforeEach(function(){
    view = new App.views.HowItWorks({el: $('<div id="foo"><div class="how-it-works"><h3>T1</h3><h3>T2</h3></div></div>')});
  });

  describe("#generateMenu", function(){
    var menu;
    beforeEach(function(){
      menu = view.generateMenu();
    });

    it("should generate menu with 2 links containing header content", function(){
      expect(_.map(menu, function(el){ return el.find('a').html(); })).toEqual(['T1', 'T2']);
    });

    it("should generate menu with 2 links with href to corresponding topics", function(){
      expect(_.map(menu, function(el){ return el.find('a').prop('href'); })).toEqual([window.location.href + '#topic_0', window.location.href + '#topic_1']);
    });
  
  });

  describe("#getHeaders", function(){
    var headers;
    beforeEach(function(){
      headers = view.getHeaders();
    });

    it("should enumerate the headers in name property", function(){
      expect(_.map(headers, function(el){ return el.prop('id'); })).toEqual(['topic_0', 'topic_1']);
    });

    it("should return array with h3 elements inside how-it-works body", function(){
      expect(_.map(headers, function(el){ return el.prop('tagName'); })).toEqual(['H3', 'H3']);
    });
  });
});
