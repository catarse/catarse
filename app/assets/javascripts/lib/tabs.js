Skull.Tabs = {
  selectTab: function($tab, $tabContent){
    $tab.siblings('.selected').removeClass('selected');
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

    if($.trim(results.html()) == '' && $tabContent.data('path') && !results.is('[data-skiptab]')){
      $.get($tabContent.data('path')).success(function(data){
        results.html(data);
      });
    }
  }
};

