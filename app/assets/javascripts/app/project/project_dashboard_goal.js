App.addChild('DashboardGoal', {
  el: '#dashboard-goal-tab',

  events:{
    "click .choose-unlimited": "chooseUnlimited",
    "click .choose-limited": "chooseLimited",
    "click .choose-mode": "chooseMode",
    "click .mode-diff-toggle": "showDiff",
    "click .fee-toggle": "showFeeExplanation",
    "change input[name='project[online_days]']": "validateDays",
    "change input[name='flexible_project[online_days]']": "validateDays",
    "blur input[name='project[online_days]']": "validateDays",
    "blur input[name='flexible_project[online_days]']": "validateDays"
  },

  chooseMode: function(event) {
    event.preventDefault();
    var $radios = $('input:radio[name="project[mode]"], input:radio[name="flexible_project[mode]"]');
    var mode = $(event.target.closest('.choose-mode')).data('mode');
    $radios.val([mode]);

    if($(event.target.closest('.choose-mode')).hasClass('choose-aon')){
      this.$('.choose-limited input').prop('disabled', true);
      this.$('.aon-days input').prop('disabled', false);
      this.$('.flex-days').hide();
      this.$('.aon-days').show();
      this.$('.flex-fee').hide();
      this.$('.aon-fee').show();
      this.$('.choose-aon').addClass('selected');
      this.$('.choose-flex').removeClass('selected');
    }
    else {
      this.$('.choose-limited input').prop('disabled', false);
      this.$('.aon-days input').prop('disabled', true);
      this.$('.flex-days').show();
      this.$('.aon-days').hide();
      this.$('.flex-fee').show();
      this.$('.aon-fee').hide();
      this.$('.choose-flex').addClass('selected');
      this.$('.choose-aon').removeClass('selected');
    }
  },

  showDiff: function(event) {
    event.preventDefault();
    var $target = this.$('.mode-diff');
    $target.slideToggle();
  },

  chooseUnlimited: function(event) {
    event.preventDefault();
    this.$('.choose-unlimited').addClass('selected');
    this.$('.choose-limited').removeClass('selected');
    this.$('.choose-limited input').val('');
  },

  chooseLimited: function(event) {
    event.preventDefault();
    this.$('.choose-unlimited').removeClass('selected');
    this.$('.choose-limited').addClass('selected');
    this.$('input[name="project[online_days]"]').focus();
  },

  showFeeExplanation: function(event) {
    event.preventDefault();
    var $target = this.$('.fee-explanation');
    $target.slideToggle();
  },

  validateDays: function (event) {
    var isFlex = this.$('.choose-flex').hasClass('selected');
    var $input = $(event.target);
    var value = Number($input.val());
    if (isFlex) {
      if (value < 1 || value > 365) {
        $input.addClass('error');
        return;
      }
    } else {
      if (value < 1 || value > 60) {
        $input.addClass('error');
        return;
      }
    }

    $input.removeClass('error');
  }
});
