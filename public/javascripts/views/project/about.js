var ProjectAboutView = ProjectContentView.extend({
  initialize: function(){
    this.setOptions({
      link: $('#about_link'),
      template: $('#project_about_template')
    })
    this.selectLink()
    this.render()
  }
})