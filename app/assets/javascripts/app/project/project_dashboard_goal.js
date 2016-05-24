App.addChild('DashboardGoal', {
  el: '#dashboard-goal-tab',

  events:{
    "click .choose-unlimited": "chooseUnlimited",
    "click .choose-limited": "chooseLimited",
    "click .choose-mode": "chooseMode",
    "click .mode-diff-toggle": "showDiff",
    "click .fee-toggle": "showFeeExplanation"
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
  },

  showFeeExplanation: function(event) {
    event.preventDefault();
    var $target = this.$('.fee-explanation');
    $target.slideToggle();
  }
});
