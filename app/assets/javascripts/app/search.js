App.addChild('Search', {
  el: '#discover-form-wrapper',

  events: {
    'click a.see-more-projects': 'goToExplore'
  },

  activate: function() {
    this.watchSearchForm();
  },

  watchSearchForm: function() {
    var that = this;
    var options = {
      wait: 300,
      highlight: true,
      captureLength: 0,
      callback: this.onTypeWatch
    };

    this.$('.search-input').typeWatch(options);
  },

  goToExplore: function() {
    this.$el.find('form.discover-form').submit();
  },

  onTypeWatch: function(value) {
    var that = this;

    if(value == "") {
      return this.$('.search-pre-result').hide();
    }

    this.$('.search-pre-result').show();

    $.get(this.$('.search-pre-result').data('searchpath'), { search_on_name: value, limit: 5 }, function(response){
      that.$('.result').html(response);
    });
  }
});
