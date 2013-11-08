Skull.ShowPasswordInput = {
  togglePass: function(inputs, checked) {

    if(checked) {
      if(typeof(inputs) == 'string') {
        $(inputs).prop('type', 'text');
      } else {
        _.each(inputs, function(item) {
          $(item).prop('type', 'text');
        })
      }
    } else {
      if(typeof(inputs) == 'string') {
        $(inputs).prop('type', 'password');
      } else {
        _.each(inputs, function(item) {
          $(item).prop('type', 'password');
        })
      }
    }

    return false;
  }
}
