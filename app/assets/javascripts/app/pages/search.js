App.addChild('Search', {
  el: '#discover-form-wrapper',

  events: {
    'click a.see-more-projects': 'goToExplore',
    'input .search-input': 'clearPreResult'
  },

  activate: function() {
    this.watchSearchForm();
  },

  watchSearchForm: function() {
    var that = this;
    var options = {
      wait: 300,
      highlight: true,
      captureLength: 3,
      callback: this.onTypeWatch
    };

    this.$('.search-input').typeWatch(options);
  },

  clearPreResult: function(event){
    if($(event.target).val() === "") {
      this.$('.search-pre-result').hide();
    }
  },

  goToExplore: function() {
    this.$el.find('form.discover-form').submit();
  },

  onTypeWatch: function(value) {
    var that = this;

    $.get(this.$('.search-pre-result').data('searchpath'), { pg_search: value, limit: 5 }, function(response){
      if($.trim(response) === "") {
        that.$('.search-pre-result').hide();
      } else {
        that.$('.search-pre-result').show();
        that.$('.result').html(response);
      }
    });
  }
});
