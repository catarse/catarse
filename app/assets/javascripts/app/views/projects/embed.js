CATARSE.ProjectsEmbedView = Backbone.View.extend({
  initialize: function() {
    $(document).ready(function(){
      $('a').attr('target', '_blank')
    })
  }
})

