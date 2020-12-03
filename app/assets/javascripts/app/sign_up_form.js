document.addEventListener('DOMContentLoaded', function() {
  let checkboxShowPassword = document.getElementById('user_show_password');
  let inputPassword = document.getElementById('user_password');

  checkboxShowPassword.addEventListener('change', function() {
    if (this.checked == true) {
      inputPassword.type = 'text';
    } else {
      inputPassword.type = 'password';
    }
  });
});
