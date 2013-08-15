describe("ReviewForm", function() {
  var view;

  beforeEach(function() {
    view = new App.views.ReviewForm({ el: $('<form style="display:none;"></form>')});
  });

  describe("#validate", function() {
    describe("when all inputs are valid", function() {
      var valid;

      beforeEach(function() {
        view.$el.append('<input required="required"/><input />');
        $('html').append(view.$el);
        var $inputs = view.$('input');
        spyOn(view, "$").andReturn($inputs);
        valid = view.validate();
      });
      
      it("should look only for visible elements", function() {
        expect(view.$).wasCalledWith('input:visible');
      });

      it("should return false", function() {
        expect(valid).toEqual(false);
      });
    });  

    describe("when all inputs are valid", function() {
      beforeEach(function() {
        view.$el.html('<input /><input />');
      });

      it("should return true", function() {
        expect(view.validate()).toEqual(true);
      });
    });  
  });  

  describe("#acceptTerms", function() {
    beforeEach(function() {
      spyOn(view, "updateBacker");
    });

    describe("when validate is true", function() {
      beforeEach(function() {
        spyOn(view, "validate").andReturn(true);
        view.acceptTerms();
      });

      it("should call updateBacker", function() {
        expect(view.updateBacker).wasCalled();
      });
    });  
    
    describe("when validate is false", function() {
      beforeEach(function() {
        spyOn(view, "validate").andReturn(false);
        view.acceptTerms();
      });

      it("should not call updateBacker", function() {
        expect(view.updateBacker).wasNotCalled();
      });
    });  
  });  

  describe("#invalid", function() {
    var input = { addClass: function(){} };

    beforeEach(function() {
      spyOn(input, "addClass");
      spyOn(view, "$").andReturn(input);
      view.invalid({ currentTarget: 'error input' })
    });

    it("should get event currentTarget", function() {
       expect(view.$).wasCalledWith('error input');
    });
    
    it("should add class to input", function() {
      expect(input.addClass).wasCalledWith('error');
    });
  });  
  
  describe("#checkInput", function() {
    var input = { removeClass: function(){} };

    beforeEach(function() {
      spyOn(input, "removeClass");
      spyOn(view, "$").andReturn(input);
    });
    
    describe("when event.currentTarget.checkValidity is false", function() {
      var currentTarget = { checkValidity: function(){ return false; } };
      beforeEach(function() {
        view.checkInput({ currentTarget: currentTarget })
      });

      it("should not call removeClass", function() {
        expect(input.removeClass).wasNotCalled();
      });
    });

    describe("when event.currentTarget.checkValidity is true", function() {
      var currentTarget = { checkValidity: function(){ return true; } };
      beforeEach(function() {
        view.checkInput({ currentTarget: currentTarget })
      });

      it("should get event currentTarget", function() {
        expect(view.$).wasCalledWith(currentTarget);
      });

      it("should remove class to input", function() {
        expect(input.removeClass).wasCalledWith('error');
      });
    });  
  });  
});

