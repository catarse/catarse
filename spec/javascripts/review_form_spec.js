RSpec.describe("ReviewForm", function() {
  var view;

  beforeEach(function() {
    view = new App.views.ReviewForm({ el: $('<form style="display:none;"></form>')});
  });

  describe("#activate", function() {
    describe("when live_in_brazil is not checked", function(){
      var el;
      beforeEach(function(){
        el = { length: 0, on: function(){}, hide: function(){} };
        spyOn(view, '$').and.returnValue(el);
        spyOn(el, "hide");
        view.activate();
      });

      it("should fadeOut address_data fieldset", function(){
        expect(view.$).toHaveBeenCalledWith("#live_in_brazil:checked");
        expect(view.$).toHaveBeenCalledWith("fieldset.address_data");
        expect(el.hide).toHaveBeenCalled();
      });

    });
  });

  describe("#validate", function() {
    describe("when all inputs are valid", function() {
      var valid;

      beforeEach(function() {
        view.$el.append('<input required="required"/><input />');
        $('html').append(view.$el);
        var $inputs = view.$('input');
        spyOn(view, "$").and.returnValue($inputs);
        valid = view.validate();
      });

      it("should look only for visible elements", function() {
        expect(view.$).toHaveBeenCalledWith('input:visible');
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
      spyOn(view, "updateContribution");
    });

    describe("when validate is true", function() {
      beforeEach(function() {
        spyOn(view, "validate").and.returnValue(true);
        view.acceptTerms();
      });

      it("should call updateContribution", function() {
        expect(view.updateContribution).toHaveBeenCalled();
      });
    });

    describe("when validate is false", function() {
      beforeEach(function() {
        spyOn(view, "validate").and.returnValue(false);
        view.acceptTerms();
      });

      it("should not call updateContribution", function() {
        expect(view.updateContribution).not.toHaveBeenCalled();
      });
    });
  });

  describe("#invalid", function() {
    var input = { addClass: function(){} };

    beforeEach(function() {
      spyOn(input, "addClass");
      spyOn(view, "$").and.returnValue(input);
      view.invalid({ currentTarget: 'error input' })
    });

    it("should get event currentTarget", function() {
       expect(view.$).toHaveBeenCalledWith('error input');
    });

    it("should add class to input", function() {
      expect(input.addClass).toHaveBeenCalledWith('error');
    });
  });

  describe("#checkInput", function() {
    var input = { removeClass: function(){} };

    beforeEach(function() {
      spyOn(input, "removeClass");
      spyOn(view, "$").and.returnValue(input);
    });

    describe("when event.currentTarget.checkValidity is false", function() {
      var currentTarget = { checkValidity: function(){ return false; } };
      beforeEach(function() {
        view.checkInput({ currentTarget: currentTarget })
      });

      it("should not call removeClass", function() {
        expect(input.removeClass).not.toHaveBeenCalled();
      });
    });

    describe("when event.currentTarget.checkValidity is true", function() {
      var currentTarget = { checkValidity: function(){ return true; } };
      beforeEach(function() {
        view.checkInput({ currentTarget: currentTarget })
      });

      it("should get event currentTarget", function() {
        expect(view.$).toHaveBeenCalledWith(currentTarget);
      });

      it("should remove class to input", function() {
        expect(input.removeClass).toHaveBeenCalledWith('error');
      });
    });
  });
});

