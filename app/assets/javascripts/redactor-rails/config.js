window.init_redactor = function(){
  var csrf_token = $('meta[name=csrf-token]').attr('content');
  var csrf_param = $('meta[name=csrf-param]').attr('content');
  var params;
  if (csrf_param !== undefined && csrf_token !== undefined) {
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
  }

  $('.redactor').redactor({
        formatting: ['p', 'blockquote', 'h1', 'h2', 'h3', 'h4'],
        lang: 'pt_br',
        maxHeight: 800,
        minHeight: 300,
        convertVideoLinks: true,
        convertUrlLinks: true,
        // You can specify, which ones plugins you need.
        // If you want to use plugins, you have add plugins to your
        // application.js and application.css files and uncomment the line below:
        // "plugins": ['fontsize', 'fontcolor', 'fontfamily', 'fullscreen', 'textdirection', 'clips'],
        plugins: ['video'],
        "imageUpload":"/redactor_rails/pictures?" + params,
        "imageGetJson":"/redactor_rails/pictures",
        "path":"/assets/redactor-rails",
        "css":"style.css"
      });
}

$(document).on( 'ready page:load', window.init_redactor );
