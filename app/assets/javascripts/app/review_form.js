App.addChild('ReviewForm', _.extend({
  el: 'form#review_form',

  events: {
    'blur input' : 'checkInput',
    'click #accept' : 'acceptTerms',
    'click #live_in_brazil' : 'toggleAddressFields',
    'keyup #user_cpf' : 'onUserDocumentKeyup'
  },

  toggleAddressFields: function(){
    this.$('fieldset.address_data').fadeToggle();
  },

  acceptTerms: function(){
    if(this.validate()){
      $('#payment').show();
      this.updateContribution();
    } else {
      return false;
    }
  },

  activate: function(){
    this.setupForm();
    if(this.$('#live_in_brazil:checked').length == 0){
      this.$('fieldset.address_data').hide();
    }
  },

  onUserDocumentKeyup: function(e) {
    var $documentField = $(e.currentTarget);
    var documentNumber = $documentField.val();
    $documentField.prop('maxlength', 18);
    var resultCpf = this.validateCpf(documentNumber);
    var resultCnpj = this.validateCnpj(documentNumber.replace(/[\/.\-\_ ]/g, ''));
    var numberLength = documentNumber.replace(/[.\-\_ ]/g, '').length
    if(numberLength > 10) {
     if($documentField.attr('id') != 'payment_card_cpf'){
         if(numberLength == 11) {$documentField.mask('999.999.999-99?999'); }//CPF
         else if(numberLength == 14 ){$documentField.mask('99.999.999/9999-99');}//CNPJ
         if(numberLength != 14 || numberLength != 11){ $documentField.unmask()}
        }

     if(resultCpf || resultCnpj) {
        $documentField.addClass('ok').removeClass('error');
      } else {
        $documentField.addClass('error').removeClass('ok');
      }
    }
     else{
        $documentField.addClass('error').removeClass('ok');
     }
  },

  updateContribution: function(){
    var contribution_data = {
      payer_name: this.$('#user_full_name').val(),
      payer_email: this.$('#user_email').val(),
      payer_document: this.$('#user_cpf').val(),
      address_street: this.$('#user_address_street').val(),
      address_number: this.$('#user_address_number').val(),
      address_complement: this.$('#user_address_complement').val(),
      address_neighbourhood: this.$('#user_address_neighbourhood').val(),
      address_zip_code: this.$('#user_address_zip_code').val(),
      address_city: this.$('#user_address_city').val(),
      address_state: this.$('#user_address_state').val(),
      address_phone_number: this.$('#user_phone_number').val()
    }
    $.post(this.$el.data('update-info-path'), {
      _method: 'put',
      contribution: contribution_data
    });
  },

  validateCpf: function(cpfString){
    var product = 0, i, digit;
    cpfString = cpfString.replace(/[.\-\_ ]/g, '');
    var aux = Math.floor(parseFloat(cpfString) / 100);
    var cpf = aux * 100;
    var quotient;

    for(i=0; i<=8; i++){
      product += (aux % 10) * (i+2);
      aux = Math.floor(aux / 10);
    }
    digit = product % 11 < 2 ? 0 : 11 - (product % 11);
    cpf += (digit * 10);
    product = 0;
    aux = Math.floor(cpf / 10);
    for(i=0; i<=9; i++){
      product += (aux % 10) * (i+2);
      aux = Math.floor(aux / 10);
    }
    digit = product % 11 < 2 ? 0 : 11 - (product % 11);
    cpf += digit;
    return parseFloat(cpfString) === cpf;
  },

  validateCnpj: function(cnpj) {
    var numeros, digitos, soma, i, resultado, pos, tamanho, digitos_iguais;
    digitos_iguais = 1;
    if (cnpj.length < 14 && cnpj.length < 15)
      return false;
    for (i = 0; i < cnpj.length - 1; i++)
    if (cnpj.charAt(i) != cnpj.charAt(i + 1))
      {
        digitos_iguais = 0;
        break;
      }
      if (!digitos_iguais)
        {
          tamanho = cnpj.length - 2
          numeros = cnpj.substring(0,tamanho);
          digitos = cnpj.substring(tamanho);
          soma = 0;
          pos = tamanho - 7;
          for (i = tamanho; i >= 1; i--)
          {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2)
              pos = 9;
          }
          resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
          if (resultado != digitos.charAt(0))
            return false;
          tamanho = tamanho + 1;
          numeros = cnpj.substring(0,tamanho);
          soma = 0;
          pos = tamanho - 7;
          for (i = tamanho; i >= 1; i--)
          {
            soma += numeros.charAt(tamanho - i) * pos--;
            if (pos < 2)
              pos = 9;
          }
          resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
          if (resultado != digitos.charAt(1))
            return false;
          return true;
        }
        else
          return false;
  }

}, Skull.Form));

