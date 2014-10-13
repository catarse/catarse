RSpec.describe("ContributionForm", function() {
  var view;
  var reward = $('<input type="radio" />');

  beforeEach(function() {
    view = new App.views.Contribution.views.ContributionForm({el: $('<div></div>')});
  });

  describe('#reward', function(){
    var reward;

    beforeEach(function() {
      spyOn(view, "$").and.returnValue({ length: 1, val: function(){return 1;} });
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
      expect(view.$).toHaveBeenCalledWith('input[type=radio]:checked');
    });
  });

  describe("#clickReward", function() {
    beforeEach(function() {
      spyOn(view, "$").and.returnValue(reward);
      spyOn(view, "selectReward");
      spyOn(view, "reward").and.returnValue({id: 1, minimum_value: 10});
      spyOn(view.value, "val");
      view.clickReward({ currentTarget: 'target' });
    });

    it("should set value to reward minimum value", function() {
      expect(view.reward).toHaveBeenCalled();
      expect(view.value.val).toHaveBeenCalledWith(10);
    });

    it("should call selectReward", function() {
      expect(view.selectReward).toHaveBeenCalledWith(reward);
    });
  });

  describe("#selectReward", function() {
    var choice = { addClass: function(){} }
    beforeEach(function() {
      spyOn(choice, "addClass");
      spyOn(reward, "prop");
      spyOn(reward, "parents").and.returnValue(choice);
      spyOn(view.choices, "removeClass");
      view.selectReward(reward);
    });

    it("should add class selected to choice where reward is in", function() {
      expect(reward.parents).toHaveBeenCalledWith('.choice:first');
      expect(choice.addClass).toHaveBeenCalledWith('selected');
    });

    it("should remove selected class from choices", function() {
      expect(view.choices.removeClass).toHaveBeenCalledWith('selected');
    });

    it("should set prop checked to true", function() {
      expect(reward.prop).toHaveBeenCalledWith('checked', true);
    });

  });

});
