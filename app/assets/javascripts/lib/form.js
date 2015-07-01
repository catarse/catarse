Skull.Form = {
  checkInput: function(event){
    var $target = this.$(event.currentTarget);
    var customValidation = $target.data('custom-validation') || function(){ return true; };
    if(event.currentTarget.checkValidity() && customValidation($target)){
      if($target.prop('id') != "" && $target.prop('id') != undefined) {
        $target.removeClass("error");
        $target.parents('.field_with_errors').removeClass('field_with_errors');
        this.$('[data-error-for=' + $target.prop('id') + ']').hide();
      }
    }
  },

  setupForm: function(){
    this.$('input,select,textarea').on('invalid', this.invalid);
    this.preventInvalidSubmit();
  },

  invalid: function(event){
    var $target = this.$(event.currentTarget);
    $target.addClass("error");
    this.$('[data-error-for=' + $target.prop('id') + ']').show();
  },

  validate: function(){
    var valid = true;
    var that = this;
    this.$('input:visible,select:visible,textarea:visible').each(function(){
      var $input = $(this);
      var customValidation = $input.data('custom-validation') || function(){ return true; };
      valid = this.checkValidity() && customValidation($input) && valid;
    });
    if(!valid){
      $.smoothScroll({
        scrollTarget: '[required].error:visible:first',
        speed: 800
      });
      this.$('[required].error:visible:first').select();
      //this.$('.text-error').slideDown('slow');
      $.each(this.$('.text-error'), function(i, item){
        if(that.$(item.parent).hasClass('error')) {
          that.$(item).slideDown('slow');
        }
      })
    }
    return valid;
  },

  preventInvalidSubmit: function(){
    var that = this;
    this.$('input[type="submit"]').on('click', function(e){
      return that.validate();
    });
  },
};
