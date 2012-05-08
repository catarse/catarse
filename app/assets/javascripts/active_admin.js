/* Active Admin JS */
//= require ./lib/jquery-1.7.1.min.js
//= require ./lib/jquery-ui-1.8.6.custom.min.js
$(function(){
  $(".datepicker").datepicker({dateFormat: 'yy-mm-dd'});

  $(".clear_filters_btn").click(function(){
    window.location.search = "";
    return false;
  });
});
