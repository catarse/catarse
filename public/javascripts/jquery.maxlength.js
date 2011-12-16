/*
 *
 * Textarea Maxlength Setter JQuery Plugin
 * Version 1.0
 *
 * Copyright (c) 2008 Viral Patel
 * website : http://viralpatel.net/blogs
 *
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
*/

jQuery.fn.maxlength = function(){

  $("textarea[maxlength]").keypress(function(event){
    var key = event.which;

    //all keys including return.
    if(key >= 33 || key == 13) {
      var maxLength = $(this).attr("maxlength");
      var length = this.value.length;
      if(length >= maxLength) {

        event.preventDefault();
      }
    }
  });

}
