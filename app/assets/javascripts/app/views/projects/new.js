CATARSE.ProjectsNewView = Backbone.View.extend({
  el: 'body',

  initialize: function() {
    var video_valid = null
    var permalink_valid = null
    everything_ok = function(){
      var all_ok = true
      if(video_valid == null) {
        all_ok = false
        verify_video()
      }
      if(permalink_valid == null) {
        all_ok = false
        verify_permalink()
      }
      if(!permalink_ok())
        all_ok = false
      if(!ok('#project_more_links'))
        all_ok = false
      if(!ok('#project_how_know'))
        all_ok = false
      if(!ok('#project_first_backers'))
        all_ok = false
      if(!ok('#project_name'))
        all_ok = false
      if(!video_ok())
        all_ok = false
      if(!ok('#project_about'))
        all_ok = false
      if(!headline_ok())
        all_ok = false
      if(!ok('#project_category_id'))
        all_ok = false
      if(!goal_ok())
        all_ok = false
      if(!online_days_ok())
        all_ok = false
      if(!accepted_terms())
        all_ok = false
      if(all_ok){
        $('#project_submit').attr('disabled', false)
      } else {
        $('#project_submit').attr('disabled', true)
      }
    }

    ok = function(id){
      var value = $(id).val()
      if(value && value.trim().length > 0){
        $(id).addClass("ok").removeClass("error")
        return true
      } else {
        $(id).addClass("error").removeClass("ok")
        return false
      }
    }

    verify_permalink = function() {
      if(/^(\w|-)*$/.test($('#project_permalink').val()))
      {
        if($('#project_permalink').val() == ''){
          permalink_valid = false
        }
        else {
        $.get('/projects/check_slug/?permalink='+$('#project_permalink').val(),
            function(r) {
              if(r.available){
                permalink_valid = true
              } else {
                permalink_valid = false
              }
              everything_ok()
        })
        }

      } else {
        permalink_valid = false
        everything_ok()
      }
    }

    permalink_ok = function(){
      if(permalink_valid){
        $('#project_permalink').addClass("ok").removeClass("error")
        return true
      } else {
        $('#project_permalink').addClass("error").removeClass("ok")
        return false
      }
    }

    verify_video = function(){
      video_valid = false
      if($('#project_video_url').val() == ''){
          video_valid = true
          everything_ok()
      }
      else if(/(https?:\/\/(www\.)?vimeo.com\/(\d+))|(youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)?|youtu\.be\/([A-Za-z0-9._%-]*)?)/.test($('#project_video_url').val())) {
        $('#project_video_url').removeClass("ok").removeClass("error").addClass('loading')
        $.get('/projects/video/?url='+$('#project_video_url').val(), function(r){
          $('#project_video_url').removeClass("loading")
          if(r.video_id==false){
            video_valid = false
          } else {
            video_valid = true
          }
          everything_ok()
        })
      }
      else{
          everything_ok()
      }
    }
    video_ok = function(){
      if(video_valid){
        $('#project_video_url').addClass("ok").removeClass("error")
        return true
      } else {
        if(!$('#project_video_url').hasClass('loading'))
          $('#project_video_url').addClass("error").removeClass("ok")
        return false
      }
    }
    headline_ok = function(){
      var value = $('#project_headline').val()
      if(value && value.trim().length > 0 && value.length <= 140){
        $('#project_headline').addClass("ok").removeClass("error")
        return true
      } else {
        $('#project_headline').addClass("error").removeClass("ok")
        return false
      }
    }
    goal_ok = function(){
      var value = $('#project_goal').val()
      if(/^(\d+)$/.test(value) && parseInt(value) > 0){
        $('#project_goal').addClass("ok").removeClass("error")
        return true
      } else {
        $('#project_goal').addClass("error").removeClass("ok")
        return false
      }
    }
    online_days_ok = function(){
      var value = $('#project_online_days').val()
      if(value && value.length > 0 && value > 0 && parseInt(value) <= 60) {
        $('#project_online_days').addClass("ok").removeClass("error")
        return true
      } else {
        $('#project_online_days').addClass("error").removeClass("ok")
        return false
      }
    }
    accepted_terms = function(){
      return $('#accept').is(':checked')
    }
    $('#project_permalink').timedKeyup(verify_permalink)
    $('#project_name').keyup(everything_ok)
    $('#project_video_url').keyup(function(){ video_valid = false; everything_ok() })
    $('#project_video_url').timedKeyup(verify_video)
    $('#project_about').keyup(everything_ok)
    $('#project_category_id').change(everything_ok)
    $('#project_goal').keyup(everything_ok)
    $('#project_online_days').keyup(everything_ok)
    $('#project_headline').keyup(everything_ok)
    $('#project_first_backers').keyup(everything_ok)
    $('#project_more_links').keyup(everything_ok)
    $('#project_how_know').keyup(everything_ok)
    $('#accept').click(everything_ok)

    $('#project_goal').numeric(false)
    $('input,textarea,select').live('focus', function(){
      $('p.inline-hints').hide()
      $(this).next('p.inline-hints').show()
    })

    $('#project_permalink').focus()
    $('textarea').maxlength()
    everything_ok();
  }
})
