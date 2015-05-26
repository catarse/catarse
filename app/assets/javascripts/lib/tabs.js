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
  },

  lookAnchors: function() {
    $anchor = this.$('#current_anchor').data('anchor') || window.location.hash || this.$('#default-tab').data('anchor');

    if(this.$('.dashboard-nav-link').length > 0) {
      selector = '.dashboard-nav-link';
    } else {
      selector = '.nav-tab';
    }

    if($anchor != '' && $anchor != undefined) {
      window.location.hash = $anchor;
    } else {
      if(this.$(selector).filter('.selected').length < 1 && (window.location.hash == '' || window.location.hash == '_#_')) {
        var clickEvent = document.createEvent('MouseEvent');
        clickEvent.initEvent('click', true, true);
        this.$(selector).filter(':first')[0].dispatchEvent(clickEvent);
      }
    }
  }
};