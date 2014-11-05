Skull.Form = {
  checkInput: function(event){
    if(event.currentTarget.checkValidity()){
      var $target = this.$(event.currentTarget);
      $target.removeClass("error");
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
    this.$('[required]:visible').each(function(){
      valid = this.checkValidity() && valid;
    });
    this.$('[required].error:visible:first').select();
    return valid;
  }
};
