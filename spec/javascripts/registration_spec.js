describe("Registration", function() {
  var view;

  beforeEach(function(){
    view = new App.views.Registration({el: $('<div id="foo"></div>')});
  });

  describe("#showPassword", function() {
    beforeEach(function() {
      spyOn(view.$password_input, 'prop');
    });

    describe("when show password is cheked", function() {
      beforeEach(function(){
        spyOn(view, '$').andReturn({prop: function() { return true; } });

        view.showPassword({target: 'checkbox_checked'});
      });

      it("should change password input type to text", function(){
        expect(view.$password_input.prop).wasCalledWith('type', 'text');
      });
    });

    describe("when show password is not cheked", function() {
      beforeEach(function(){
        spyOn(view, '$').andReturn({prop: function() { return false; } });

        view.showPassword({target: 'unchecked_checkbox'});
      });

      it("should change password input type to text", function(){
        expect(view.$password_input.prop).wasCalledWith('type', 'password');
      });
    });

  });
});
