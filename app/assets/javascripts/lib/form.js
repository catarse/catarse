Skull.Form = {
  checkInput: function(event){
    var $target = this.$(event.currentTarget);
    var customValidation = $target.data('custom-validation') || function(){ return true; };
    if(event.currentTarget.checkValidity() && customValidation($target)){
      $target.removeClass("error");
      $target.parents('.field_with_errors').removeClass('field_with_errors');
      this.$('[data-error-for=' + $target.prop('id') + ']').hide();
    }
  },

  setupForm: function(){
    this.$('input,select,textarea').on('invalid', this.invalid);
  },

  invalid: function(event){
    var $target = this.$(event.currentTarget);
    $target.addClass("error");
    this.$('[data-error-for=' + $target.prop('id') + ']').show();
  },

  validate: function(){
    var valid = true;
    this.$('input:visible,select:visible,textarea:visible').each(function(){
      var $input = $(this);
      var customValidation = $input.data('custom-validation') || function(){ return true; };
      valid = this.checkValidity() && customValidation($input) && valid;
    });
    this.$('[required].error:visible:first').select();
    return valid;
  },
};
