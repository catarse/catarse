CATARSE.UsersShowView = Backbone.View.extend({

	initialize: function() {
		CATARSE.router.route("", "index", this.index)
		CATARSE.router.route("backs", "backs", this.backs)
	},
	
	index: function() {
	},
	
	backs: function() {
		
	}
})

$('input,textarea').live('keypress', function(e){
  if (e.which == '13' && $("button:contains('OK')").attr('disabled')) {
    e.preventDefault();
  }
})
$('#user_feed input').live('keyup', function(){
  var value = $(this).val()
  var re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
  if(value.match(re)){
    $(this).addClass("ok").removeClass("error")
    $("button:contains('OK')").attr('disabled', false)
  } else {
    $(this).addClass("error").removeClass("ok")
    $("button:contains('OK')").attr('disabled', true)
  }
})
$('#content_header textarea').live('keyup', function(){
  var value = $(this).val()
  if(value.length <= 140){
    $(this).addClass("ok").removeClass("error")
    $("button:contains('OK')").attr('disabled', false)
  } else {
    $(this).addClass("error").removeClass("ok")
    $("button:contains('OK')").attr('disabled', true)
  }
})
$('input[type=checkbox]').click(function(){
  $.post('/users/update_attribute_on_the_spot', {
    id: 'user__' + $(this).attr('id') + '__' + $('#id').val(),
    value: ($(this).is(':checked') ? 1 : null)
  })
})
