Skull.Tabs = {
  selectTab: function($tab, $tabContent){
    var $group = $('[data-tab-group=' + $tab.data('tab-group') + ']');
    if($group.length == 0){
      $group = $tab.siblings('.selected');
    }
    $group.removeClass('selected');
    $tab.addClass('selected');
    $tabContent.siblings(':visible').hide();
    $tabContent.show();
    this.trigger('selectTab');
  },

  onTabClick: function(event){
    var $tab = $(event.currentTarget);
    var $tabContent = this.$($tab.data('target'));
    this.loadTab($tabContent);
    this.selectTab($tab, $tabContent);
    return false;
  },

  loadTab: function($tabContent){
    var that = this;
    var results = $tabContent.find('.results');

    if($tabContent.data('path') && !results.data('skiptab')){
      $.get($tabContent.data('path')).success(function(data){
        results.data('skiptab', true);
        results.html(data);
      });
    }
  }
};

