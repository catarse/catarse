//Contributions.model.js
var Contributions = function(data){
  data = data || {}
  this.id = m.prop(data.id)
  this.name = m.prop(data.name)
  this.email = m.prop(data.email)
}
Contributions.list = function(data) {

  var data = [];
  
  //quick manual factory
  for(var i = 0; i < 5; i++){
    data[i] = {
      id: i,
      name: 'Contribuidor_'+i,
      email: 'teste'+i+'@teste.com'
    };
  }

  return data;
  //return m.request({method: "GET", url: "http://api.catarse.me/contributions", data: data});
}

app.Contributions = Contributions;