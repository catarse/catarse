Skull.Form = {
  checkInput: function(event){
    if(event.currentTarget.checkValidity()){
      var $target = this.$(event.currentTarget);
      $target.removeClass("error");
      this.$('[data-for=' + $target.prop('id') + ']').hide();
    }
  },

  setupForm: function(){
    this.$('input').on('invalid', this.invalid);
  },

  invalid: function(event){
    var $target = this.$(event.currentTarget);
    $target.addClass("error");
    this.$('[data-for=' + $target.prop('id') + ']').show();
  },

  validate: function(){
    var valid = true;
    this.$('input:visible').each(function(){
      valid = valid && this.checkValidity();
    });
    this.$('input.error:visible:first').select();
    return valid;
  }
};
