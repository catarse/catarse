App.views.Project.addChild('ProjectSidebar', {
  el: '.sidebar',

  events:{
    "click .show_reward_form": "showRewardForm"
  },
  
  activate: function() {
    if(this.$("#rewards_authorization").data("can_update") == true){
      this.$('#rewards').sortable({
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
    this.$($target.data('target')).fadeIn('fast');
  }
});

