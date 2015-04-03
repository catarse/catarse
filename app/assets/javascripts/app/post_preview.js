App.addChild('PostPreview', {
  el: '.use-preview',

  activate: function(){
    var that = this;
    this.$('.post-preview').hide();
    this.$('.preview-input').typeWatch({
      wait: 500,
      highlight: true,
      captureLength: 0,
      callback: function(value){
        that.convertTextToHtml(value);
      }
    });
  },

  convertTextToHtml: function(text) {
    var that = this;
    $.get('/post_preview', {text: text}, function(data) {
      that.$('.post-preview').show();
      that.$('.post-preview .preview').html(data);
    });

    return void(0);
  }
});
