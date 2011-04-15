var ProjectCollection = PaginatedCollection.extend({
  action: "",
  controller: "projects",
  initialize: function(options){
    this.initializeProject(options.project)
  },
  url: function(){
    return "/" + this.controller + "/" + this.project.get('id') + "/" + this.action + ".json?page=" + this.page
  },
  initializeProject: function(){
    this.initializePages(project)
    this.project = project
    this.models = []
  }
})
