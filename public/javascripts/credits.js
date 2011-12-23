$script.ready('final', function(){
  $('table a').click(function(e){
    e.preventDefault()
    if(confirm(confirm_text)){
      var backer_id = $(this).parent().parent().parent().attr('id')
      $('#' + backer_id + ' .text').hide()
      $('#' + backer_id + ' .loading').show()
      $.post('/credits/refund', {
        backer_id: backer_id
      }, function(r){
        $('#' + r.backer_id + ' .loading').hide()
        if(r.ok){
          $('#' + r.backer_id + ' .text').html("Solicitado estorno")      
          $('#' + r.backer_id + ' .text').show()
          $('#current_credits').html(r.credits)
        } else {
          $('#' + r.backer_id + ' .error').html(r.message)
          $('#' + r.backer_id + ' .error').show()
        }
      })
    }
  })
})
