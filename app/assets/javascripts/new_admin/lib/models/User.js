var User = function(data){
  data = data || {};  
  this.id = m.prop(data.id);
  this.name = m.prop(data.name);
  this.email = m.prop(data.email);
};

User.get = function(filter){

  var data = [];
  //quick manual factory
  for(var i = 0; i < 5; i++){
    data[i] = {
      id : i,
      name : 'project_'+i,
      user_id : i,
      email: 'email_'+i+'@email.com'
    };
  }
  return data;
  //return m.postgrest.request({method: "GET", url: "/users", data: filter});
};

admin_app.User = User;