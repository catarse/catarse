describe("Explore", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Explore();
  });
  
  describe("#activate", function() {
    it("should assing loader", function() {
      expect(view.$loader).toEqual(jasmine.any(Object));
    });
    
    it("should assing results", function() {
      expect(view.$results).toEqual(jasmine.any(Object));
    });
    
    it("should assign default filters", function() {
      expect(view.filter).toEqual({
        recommended: true,
        not_expired: true,
        page: 0
      });
    });
  });

  describe("#fetchPage", function() {
    beforeEach(function() {
      spyOn(view.$loader, "show");
      view.fetchPage();
    });

    it("should show loader", function() {
      expect(view.$loader.show).wasCalled();
    });
  });

  describe("#onSuccess", function() {
    beforeEach(function() {
      spyOn(view.$results, "append");
      spyOn(view.$loader, "hide");
      
      view.onSuccess('test data');
    });

    it("should append data to $results", function() {
      expect(view.$results.append).wasCalledWith('test data');
    });
    
    it("should show loader", function() {
      expect(view.$loader.hide).wasCalled();
    });
  });  
});  

