App.views.Project.addChild('ProjectSidebar', _.extend({
  el: '.sidebar',

  events:{
    //"click .show_reward_form": "showRewardForm"
    "click .show_reward_form": "openModalClick",
    "click #rewards .box.clickable" : "selectReward"
  },

  selectReward: function(event){
    var url = this.$(event.currentTarget).data('new_backer_url');
    this.navigate(url);
    return false;
  },

  activate: function() {
    this.$rewards = this.$('#rewards');
    this.sortableRewards();
    this.observeRemoteForms();
    this.reloadRewards();
  },

  reloadRewards: function() {
    var that = this;
    $.get(that.$rewards.data('index_path')).success(function(data){
      that.$rewards.html(data);
    });
  },

  observeRemoteForms: function() {
    var that = this;
    $(document).on('ajax:success', '.remote-form', function(evt, data, status, xhr){
      //NOTE: when data is empty html string we should close the modal.
      // But we need to find a better solution for this ;)
      if($.trim(data) == "") {
        that.$('.skull-modal-close').click();
        that.reloadRewards();
      } else {
        $(evt.target).html(data);
      }
    });
  },

  sortableRewards: function() {
    if(this.$rewards.data("can_update") == true){
      this.$rewards.sortable({
        axis: 'y',
        placeholder: "ui-state-highlight",
        start: function(e, ui) {
          return ui.placeholder.height(ui.item.height());
        },
        stop: function(e, ui) {
          return ui.item.effect('highlight', {}, 1000);
        },
        update: function(e, ui) {
          var csrfToken, position;
          position = ui.item.index();
          csrfToken = $("meta[name='csrf-token']").attr("content");
          return $.ajax({
            type: 'POST',
            url: ui.item.data('update_url'),
            dataType: 'json',
            headers: {
              'X-CSRF-Token': csrfToken
            },
            data: {
              reward: {
                row_order_position: position
              }
            }
          });
        }
      })    
    }
  },


  showRewardForm: function(event) {
    event.preventDefault();
    var $target = this.$(event.currentTarget);
    $target.fadeOut('fast');

    $.get($target.data('path')).success(function(data){
      $($target.data('target')).html(data);
    });

    this.$($target.data('target')).fadeIn('fast');
  }
}, Skull.Modal));

