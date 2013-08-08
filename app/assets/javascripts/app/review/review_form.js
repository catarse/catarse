App.views.Review.addChild('ReviewForm', {
  el: 'form#review_form',

  validate: function(){
    this.el.checkValidity();
  },

  activate: function(){
    this.$('input').on('invalid', function(data){
      console.log('error', data);
    });
  }
});

