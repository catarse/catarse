describe("ProjectSidebar", function() {
  var view;

  beforeEach(function() {
    view = new App.views.Project.views.ProjectSidebar({el: $('<div></div>')});
  });

  describe("#selectReward", function(){
    var reward = { data: function(){} };
    beforeEach(function() {
      spyOn(view, "$").andReturn(reward);
      spyOn(reward, "data").andReturn('url');
      spyOn(view, "navigate");
      view.selectReward({ currentTarget: 'reward' });
    });

    it("should get reward and get its url", function() {
      expect(view.$).wasCalledWith('reward');
      expect(reward.data).wasCalledWith('new_contribution_url');
    });

    it("should navigate to URL", function() {
      expect(view.navigate).wasCalledWith('url');
    });
  });

  describe("#sortableRewards", function() {
    beforeEach(function() {
      spyOn(view.$rewards, "sortable");
    });

    describe("when I can update rewards", function() {
      beforeEach(function() {
        spyOn(view.$rewards, "data").andReturn(true);
        view.sortableRewards();
      });

      it("should test can_update", function() {
        expect(view.$rewards.data).wasCalledWith('can_update');
      });

      it("should call sortable", function() {
        expect(view.$rewards.sortable).wasCalledWith({
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
        spyOn(view.$rewards, "data").andReturn(false);
        view.sortableRewards();
      });

      it("should test can_update", function() {
        expect(view.$rewards.data).wasCalledWith('can_update');
      });

      it("should not call sortable", function() {
        expect(view.$rewards.sortable).wasNotCalled();
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
      spyOn(view, "$").andCallFake(function(el){
        return (el == 'selector' ? form : event.currentTarget);
      });
      spyOn(event.currentTarget, "fadeOut");
      spyOn(form, "fadeIn");
      view.showRewardForm(event);
    });

    it("should call fadeOut on currentTarget element", function() {
      expect(event.currentTarget.fadeOut).wasCalled();
    });

    it("should call fadeIn on data('target') of currentTarget", function() {
      expect(view.$).wasCalledWith('selector');
      expect(form.fadeIn).wasCalled();
    });

    it("should call preventDefault", function() {
       expect(event.preventDefault).wasCalled();
    });
  });

});
