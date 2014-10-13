RSpec.describe("ProjectSidebar", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.ProjectSidebar({el: $('<div></div>')});
  });

  describe("#selectReward", function(){
    var reward = { data: function(){} };
    beforeEach(function() {
      spyOn(view, "$").and.returnValue(reward);
      spyOn(reward, "data").and.returnValue('url');
      spyOn(view, "navigate");
      view.selectReward({ currentTarget: 'reward' });
    });

    it("should get reward and get its url", function() {
      expect(view.$).toHaveBeenCalledWith('reward');
      expect(reward.data).toHaveBeenCalledWith('new_contribution_url');
    });

    it("should navigate to URL", function() {
      expect(view.navigate).toHaveBeenCalledWith('url');
    });
  });

  describe("#sortableRewards", function() {
    beforeEach(function() {
      spyOn(view.$rewards, "sortable");
    });

    describe("when I can update rewards", function() {
      beforeEach(function() {
        spyOn(view.$rewards, "data").and.returnValue(true);
        view.sortableRewards();
      });

      it("should test can_update", function() {
        expect(view.$rewards.data).toHaveBeenCalledWith('can_update');
      });

      it("should call sortable", function() {
        expect(view.$rewards.sortable).toHaveBeenCalledWith({
          axis: 'y',
          placeholder: "ui-state-highlight",
          start: jasmine.any(Function),
          stop: jasmine.any(Function),
          update: jasmine.any(Function)
        });
      });
    });

    describe("when I can not update rewards", function() {
      beforeEach(function() {
        spyOn(view.$rewards, "data").and.returnValue(false);
        view.sortableRewards();
      });

      it("should test can_update", function() {
        expect(view.$rewards.data).toHaveBeenCalledWith('can_update');
      });

      it("should not call sortable", function() {
        expect(view.$rewards.sortable).not.toHaveBeenCalled();
      });
    });
  });

  describe("#showNewRewardForm", function() {
    var event = {
      preventDefault: function() {},
      currentTarget: {
        data: function(){ return 'selector'; },
        fadeOut: function(){}
      }
    };
    var form = {
      fadeIn: function(){}
    };

    beforeEach(function() {
      spyOn(event, "preventDefault");
      spyOn(view, "$").and.callFake(function(el){
        return (el == 'selector' ? form : event.currentTarget);
      });
      spyOn(event.currentTarget, "fadeOut");
      spyOn(form, "fadeIn");
      view.showRewardForm(event);
    });

    it("should call fadeOut on currentTarget element", function() {
      expect(event.currentTarget.fadeOut).toHaveBeenCalled();
    });

    it("should call fadeIn on data('target') of currentTarget", function() {
      expect(view.$).toHaveBeenCalledWith('selector');
      expect(form.fadeIn).toHaveBeenCalled();
    });

    it("should call preventDefault", function() {
       expect(event.preventDefault).toHaveBeenCalled();
    });
  });

});
