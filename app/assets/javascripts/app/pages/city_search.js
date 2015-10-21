App.addChild('CitySearch', {
  el: '#city-input-wrapper',

  events: {
    'input .city-search-input': 'clearPreResult',
    'click .city-select': 'chooseCity'
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
      callback: this.ontypewatch
    };

    this.$('.city-search-input').typeWatch(options);
  },

  chooseCity: function(event) {
    this.$('.city-search-input').val($(event.target).html().trim());
    this.$('#project_city_id').val($(event.target).data('city-id'));
    this.$('.search-pre-result').hide();
  },

  clearPreResult: function(event){
    if($(event.target).val() === "") {
      this.$('.search-pre-result').hide();
    }
  },

  ontypewatch: function(value) {
    var that = this;

    $.get($('#city-input-wrapper').data('searchpath'), { pg_search: value }, function(response){
      if($.trim(response) === "") {
        that.$('.search-pre-result').hide();
      } else {
        that.$('.search-pre-result').show();
        that.$('.search-pre-result').html(response);
      }
    });
  }
});
