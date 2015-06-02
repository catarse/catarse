App.addChild('ProjectForm', _.extend({
  el: '.project-form',

  events: {
    'blur input' : 'checkInput',
  },

  activate: function(){
    this.setupForm();
  }

}, Skull.Form));

// Put subview here to avoid dependency issues

App.views.ProjectForm.addChild('VideoUrl', {
  el: 'input#project_video_url',

  checkVideoUrl: function(){
    var that = this;
    $.get(this.$el.data('path') + '?url=' + encodeURIComponent(this.$el.val())).success(function(data){
      if(!data || !data.provider){
        that.$el.trigger('invalid');
      }
    });
  },

  activate: function(){
    this.$el.typeWatch({
      wait: 750,
      callback: this.checkVideoUrl
    });
  }
});

App.views.ProjectForm.addChild('Permalink', {
  el: 'input#project_permalink',

  checkPermalink: function(){
    var that = this;
    if(this.re.test(this.$el.val())){
      $.get('/pt/' + this.$el.val()).complete(function(data){
        if(data.status != 404){
          that.$el.trigger('invalid');
        }
      });
    }
  },

  activate: function(){
    this.re = new RegExp(this.$el.prop('pattern'));
    this.$el.typeWatch({
      wait: 750,
      callback: this.checkPermalink
    });
  }
});

