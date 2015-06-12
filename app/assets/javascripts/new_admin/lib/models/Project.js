//Project MODEL
var Project = function(data){
  data = data || {};  
  this.id = m.prop(data.id);
  this.name = m.prop(data.name);
  this.user_id = m.prop(data.user_id);
  this.permalink = m.prop(data.permalink);
  this.uploaded_image = m.prop(data.uploaded_image);
  this.created_at = m.prop(data.created_at);
  this.updated_at = m.prop(data.updated_at);
  this.expires_at = m.prop(data.expires_at);
};

Project.get = function(filter) {

  var data = [];
  //quick manual factory
  for(var i = 0; i < 5; i++){
    data[i] = {
      id : i,
      name : 'project_'+i,
      user_id : i,
      permalink : '/sample_link_'+i,
      uploaded_image : 'http://sampleimg.com',
      created_at : Date.now(),
      updated_at : Date.now(),
      expires_at : Date.now()+10000
    };
  }
  return data;
  //return m.postgrest.request({method: "GET", url: "/projects", data: filter});
};

admin_app.Project = Project;