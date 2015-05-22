App.addChild('UserDocumentView', _.extend({
  el: '[data-validate-cpf-cnpj]',

  events: {
    'focus' : 'onUserDocumentFocus'
  },

  activate: function() {
    this.$el.data('custom-validation', this.onUserDocumentChange);
  },

  onUserDocumentFocus: function(e) {
    var $documentField = $(e.currentTarget);
    $documentField.fixedMask('off');
  },

  onUserDocumentChange: function(input) {
    var $documentField = input;
    var documentNumber = $documentField.val();
    if(documentNumber.length === 0){
      return true;
    }
    $documentField.prop('maxlength', 18);
    var resultCpf = this.validateCpf(documentNumber);
    var resultCnpj = this.validateCnpj(documentNumber.replace(/[\/.\-\_ ]/g, ''));
    var numberLength = documentNumber.replace(/[.\-\_ ]/g, '').length;
    if(numberLength > 10) {
      if($documentField.attr('id') != 'payment_card_cpf'){
        $documentField.fixedMask('off');
        if(numberLength == 11) {$documentField.fixedMask('999.999.999-99'); }//CPF
        else if(numberLength == 14 ){$documentField.fixedMask('99.999.999/9999-99');}//CNPJ
      }

      if(resultCpf || resultCnpj) {
        return true;
      } else {
        $documentField.trigger('invalid');
        return false;
      }
    }
    else{
      $documentField.trigger('invalid');
      return false;
    }
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
          tamanho = cnpj.length - 2;
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
