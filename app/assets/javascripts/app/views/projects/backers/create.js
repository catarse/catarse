CATARSE.ReviewForm = Backbone.View.extend({
  el: '#review_form',

  accepted_terms: function(){
    return $('#accept').is(':checked')
  },

  liveInBrazil: function() {
    return $('#live_in_brazil').is(':checked')
  },

  everything_ok: function(){
    var ok = function(id){
      var value = $(id).val()
      if(value && value.length > 0){
        $(id).addClass("ok").removeClass("error")
        return true
      } else {
        $(id).addClass("error").removeClass("ok")
        return false
      }
    };

    var email_ok = function(){
      var value = $('#user_email').val()
      var re = /^[a-z0-9\._-]+@([a-z0-9][a-z0-9-_]*[a-z0-9-_]\.)+([a-z-_]+\.)?([a-z-_]+)$/
      if(value.match(re)){
        $('#user_email').addClass("ok").removeClass("error")
        return true
      } else {
        $('#user_email').addClass("error").removeClass("ok")
        return false
      }
    };

    var phone_number_ok = function(){
      var value = $('#user_phone_number').val()
      var re = /^\([0-9]{2}\)[0-9]{4}-[0-9]{4}[0-9_ ]?$/
      if(value.match(re)){
        $('#user_phone_number').addClass("ok").removeClass("error")
        return true
      } else {
        $('#user_phone_number').addClass("error").removeClass("ok")
        return false
      }
    };

    var zip_code_ok = function(){
      if(zip_code_valid){
        $('#user_address_zip_code').addClass("ok").removeClass("error")
        return true
      } else if(/^[0-9]{5}-[0-9]{3}$/i.test($('#user_address_zip_code').val())) {
        if(!$('#user_address_zip_code').hasClass('loading'))
          $('#user_address_zip_code').removeClass("error").removeClass("ok")
        return true
      } else {
        if(!$('#user_address_zip_code').hasClass('loading'))
          $('#user_address_zip_code').addClass("error").removeClass("ok")
        return false
      }
    };

    var all_ok = true
    if($('#backer_credits').val() == "false"){
      if(!ok('#user_full_name'))
        all_ok = false
      if(!email_ok())
        all_ok = false
      if(this.liveInBrazil()){
        if(!phone_number_ok())
          all_ok = false
        if(!ok('#user_address_street'))
          all_ok = false
        if(!ok('#user_address_number'))
          all_ok = false
        if(!ok('#user_address_neighbourhood'))
          all_ok = false
        if(!ok('#user_address_city'))
          all_ok = false
      }
    }

    if(!this.accepted_terms()){
      all_ok = false;
    }

    if(all_ok){
      this.updateCurrentBackerInfo();
      $('#user_submit').attr('disabled', false)
      if($('#back_with_credits').length < 1) {
        if(this.allOkToMoIP() && this.liveInBrazil()) {
          $('nav#payment_menu a#moip').show();
          $('nav#payment_menu a#moip').addClass('enabled');
          $('#moip_payment').show();
          $('.tab_container #payment_menu a.enabled:first').trigger('click')
        } else {
          $('nav#payment_menu a#moip').hide();
          $('nav#payment_menu a#moip').removeClass('enabled');
          $('#moip_payment').hide();
          $('.tab_container #payment_menu a.enabled:first').trigger('click')
        }
        $('#payment.hide').show();
      }
    } else {
      $('#payment.hide').hide();
      if($('#back_with_credits').length < 1) {
        $('#user_submit').attr('disabled', true)
      }
    }
  },

  allOkToMoIP: function() {
    var street = $('#user_address_street').val();
    var number = $('#user_address_number').val();
    var phone = $('#user_phone_number').val();
    var state = $('#user_address_state').val();
    var city = $('#user_address_city').val();

    var ok = true;
    var phone_regex = /^\([0-9]{2}\)[0-9]{4}-[0-9]{4}[0-9_ ]?$/

    if(street.length < 1) { ok = false }
    if(number.length < 1) { ok = false }
    if(!phone.match(phone_regex)){ ok = false }
    if(state.length < 1) { ok = false }
    if(city.length < 1) { ok = false }

    return ok;
  },

  events:{
    'keyup input[type=text]' : 'everything_ok',
    'click #accept' : 'everything_ok',
    'click #live_in_brazil' : 'showUpAddressForm',
    'change select' : 'everything_ok',
    'keyup #user_address_zip_code' : 'onZipCodeKeyUp',
  },

  showUpAddressForm: function(e) {
    if(this.liveInBrazil()) {
      $('fieldset.address_data').fadeIn();
      if(this.accepted_terms()) {
        $('#accept').trigger('click');
        $('#accept').attr('checked', true);
      }
    } else {
      $('fieldset.address_data').fadeOut();
      if(this.accepted_terms()) {
        $('#accept').trigger('click');
        $('#accept').attr('checked', true);
      }
    }
  },

  onPaymentTabClick: function(e){
    $('.payments_type').hide();
    $('.tab_container #payment_menu a').removeClass('selected');
    e.preventDefault();
    var reference = $(e.currentTarget).attr('href');
    var remote_url = $(e.currentTarget).data('target');
    $(e.currentTarget).addClass('selected');
    $(reference).fadeIn(300);
    if($('div', reference).length <= 0) {
      $.get(remote_url, function(response){
        $(reference).empty().html(response);
      });
    }
  },

  onZipCodeKeyUp: function(){
    zip_code_valid = false;
    this.everything_ok()
  },

  initialize: function() {
    var zip_code_valid = null
    var _this = this;

    $('#user_address_zip_code').mask("99999-999")
    $('#user_phone_number').mask("(99)9999-9999?9")

    if(this.accepted_terms()){
      this.everything_ok();
    }

    if(!this.liveInBrazil()) {
      $('fieldset.address_data').hide();
    }

    var can_submit_to_moip = true;
  },

  updateCurrentBackerInfo: function() {
    var backer_id = $('input#backer_id').val();
    var project_id = $('input#project_id').val();
    var backer_data = {
      payer_name: $('#user_full_name').val(),
      payer_email: $('#user_email').val(),
      address_street: $('#user_address_street').val(),
      address_number: $('#user_address_number').val(),
      address_complement: $('#user_address_complement').val(),
      address_neighbourhood: $('#user_address_neighbourhood').val(),
      address_zip_code: $('#user_address_zip_code').val(),
      address_city: $('#user_address_city').val(),
      address_state: $('#user_address_state').val(),
      address_phone_number: $('#user_phone_number').val()
    }
    $.post('/projects/'+project_id+'/backers/'+backer_id+'/update_info', {
      backer: backer_data
    });
  }
});

CATARSE.BackersCreateView = Backbone.View.extend({
  events:{
    'click .tab_container #payment_menu a' : 'onPaymentTabClick'
  },

  onPaymentTabClick: function(e){
    $('.payments_type').hide();
    $('.tab_container #payment_menu a').removeClass('selected');
    e.preventDefault();
    var reference = $(e.currentTarget).attr('href');
    var remote_url = $(e.currentTarget).data('target');
    $(e.currentTarget).addClass('selected');
    $(reference).fadeIn(300);
    if($('div', reference).length <= 0) {
      $.get(remote_url, function(response){
        $(reference).empty().html(response);
      });
    }
  },

  initialize: function() {
    $('.payments_type').hide();
    $('.tab_container #payment_menu a').removeClass('selected');
    this.$('.tab_container #payment_menu a.enabled:first').trigger('click')
    this.reviewForm = new CATARSE.ReviewForm();
  }
})
