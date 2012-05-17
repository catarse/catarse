CATARSE.ProjectsPendingView = Backbone.View.extend({
  initialize: function() {
    $('input[type=checkbox]').click(function(){
      var data = $(this).attr('id').split('__')
      var klass = data[0]
      var field = data[1]
      var id = data[2]
      $.post('/projects/update_attribute_on_the_spot', {
        id: klass + '__' + field + '__' + id,
        value: ($(this).is(':checked') ? 1 : null)
      })
    })
  }
})
