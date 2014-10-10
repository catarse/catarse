App.addChild('Search', {
  el: '.discover-form',

  events: {
    'click .see-more-projects a': 'goToExplore'
  },

  activate: function() {
    this.watchSearchForm();
  },

  watchSearchForm: function() {
    var that = this;

    this.$('.discover-form-input').typeWatch({
      wait: 300,
      highlight: true,
      captureLength: 0,
      callback: function(value) {
        if(value == "") {
          return that.$('.search-pre-result').hide();
        }
        that.$('.search-pre-result').show();

        $.get('/auto_complete_projects', { search_on_name: value, limit: 5 }, function(response){
          that.$('.result').html(response);
        });
      }
    });
  },

  goToExplore: function() {
    this.el.submit();
  },
});
