var CATARSE = {

  loader: CATARSE_LOADER,
  locale: $(document.body).data("locale"),
  currentUser: $(document.body).data("user"),
      
  requireLogin: function(event, customUrl){
    event.preventDefault()
    var url = null
    if(typeof(customUrl) != 'undefined') {
      url = customUrl
    } else {
      if($(this).is('a')){
        url = $(this).attr('href')
      } else {
        url = $(this).parentsUntil('form').parent().attr('action')
      }
    }
    $('#return_to').val(url)
    $('#login_overlay').show()
    $('#login').fadeIn()
  },
  
  common: {
    init: function(){
      // Common init for every action
      CATARSE.router = new CATARSE.Router()
    },

    finish: function(){
      // Common finish for every action
      if (Backbone.history)
        Backbone.history.start()
    }
  }

}
