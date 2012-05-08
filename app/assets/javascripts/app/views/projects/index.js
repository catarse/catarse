CATARSE.ProjectsIndexView = Backbone.View.extend({
  initialize: function() {
    $('#press img').mouseover(function(){
      var src = /\/(\w+)_pb.png\?*\d*$/.exec($(this).attr('src'))
      if(!src)
        return
      src = src[1]
      $(this).attr('src', '/assets/press/' + src + '.png')
    })
    $('#press img').mouseleave(function(){
      var src = /\/(\w+).png\?*\d*$/.exec($(this).attr('src'))
      if(!src)
        return
      src = src[1]
      $(this).attr('src', '/assets/press/' + src + '_pb.png')
    })
    $(function(){
      $('#curated_link').click(function(){
        $(document).scrollTo('.curated_page_header', 800);
      });
    });
  }
})

