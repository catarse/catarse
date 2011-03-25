$('table a').click(function(e){
  e.preventDefault()
  var backer_id = $(this).parent().parent().parent().attr('id')
  $('#' + backer_id + ' .text').hide()
  $('#' + backer_id + ' .loading').show()
  $.post('/credits/refund', {
    backer_id: backer_id
  }, function(r){
    if(r.ok)
      $('#' + r.backer_id + ' .text').html("Solicitado estorno")
    $('#' + r.backer_id + ' .loading').hide()
    $('#' + r.backer_id + ' .text').show()
  })
})