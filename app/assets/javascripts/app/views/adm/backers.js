CATARSE.Adm.Backers = {
  Index: Backbone.View.extend({
    events: {
      'click input[type=checkbox]': 'updateOnSpot'
    },

    updateOnSpot: function(e) {
      var target = e.currentTarget;
      var id = $(target).parent().parent().attr('id');
      var field = $(target).attr('id').split('__')[0];
      $.post('/adm/backers/update_attribute_on_the_spot', {
        id: 'backer__' + field + '__' + id,
        value: ($(e.currentTarget).is(':checked') ? true : false)
      })
    },
  })
};
