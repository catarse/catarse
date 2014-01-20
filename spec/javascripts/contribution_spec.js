describe("Contribution", function() {
  var view;
  var reward = $('<input type="radio" />');

  beforeEach(function() {
    view = new App.views.Contribution({el: $('<div></div>')});
  });

  describe('#reward', function(){
    var reward;

    beforeEach(function() {
      spyOn(view, "$").andReturn({ length: 1, val: function(){return 1;} });
      view.rewards = [
        {id: 1},
        {id: 2}
      ];
      reward = view.reward();
    });

    it("should return reward using id from selector result", function() {
      expect(reward).toEqual({id: 1});
    });

    it("should search for selected reward", function() {
      expect(view.$).wasCalledWith('input[type=radio]:checked');
    });
  });

  describe("#clickReward", function() {
    beforeEach(function() {
      spyOn(view, "$").andReturn(reward);
      spyOn(view, "selectReward");
      spyOn(view, "reward").andReturn({id: 1, minimum_value: 10});
      spyOn(view.value, "val");
      view.clickReward({ currentTarget: 'target' });
    });

    it("should set value to reward minimum value", function() {
      expect(view.reward).wasCalled();
      expect(view.value.val).wasCalledWith(10);
    });

    it("should call selectReward", function() {
      expect(view.selectReward).wasCalledWith(reward);
    });
  });

  describe("#selectReward", function() {
    var choice = { addClass: function(){} }
    beforeEach(function() {
      spyOn(choice, "addClass");
      spyOn(reward, "prop");
      spyOn(reward, "parents").andReturn(choice);
      spyOn(view.choices, "removeClass");
      view.selectReward(reward);
    });

    it("should add class selected to choice where reward is in", function() {
      expect(reward.parents).wasCalledWith('.choice:first');
      expect(choice.addClass).wasCalledWith('selected');
    });

    it("should remove selected class from choices", function() {
      expect(view.choices.removeClass).wasCalledWith('selected');
    });

    it("should set prop checked to true", function() {
      expect(reward.prop).wasCalledWith('checked', true);
    });

  });

});
