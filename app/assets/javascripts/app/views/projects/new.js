CATARSE.ProjectsNewView = Backbone.View.extend({
  el: 'body',

  initialize: function() {
    verify_permalink = function() {
      if(/^(\w|-)*$/.test($('#project_permalink').val()))
      {
        if($('#project_permalink').val() == ''){
          $('#project_permalink').addClass("error").removeClass("ok")
        }
        else {
        $.get('/projects/check_slug/?permalink='+$('#project_permalink').val(),
            function(r) {
              if(r.available){
                $('#project_permalink').addClass("ok").removeClass("error")
              } else {
                $('#project_permalink').addClass("error").removeClass("ok")
              }
        })
        }

      } else {
        $('#project_permalink').addClass("error").removeClass("ok")
      }
    }

    $('#project_permalink').timedKeyup(verify_permalink)

    $('#project_goal').numeric(false)
    $('input,textarea,select').live('focus', function(){
      $('p.inline-hints').hide()
      $(this).next('p.inline-hints').show()
    })

    $('#project_permalink').focus()
    $('textarea').maxlength()
  }
})
