//Contributions.model.js
var Contribution = function(data){
  data = data || {}
    this.id = m.prop(data.id)
    this.name = m.prop(data.name)
    this.email = m.prop(data.email)
}
Contribution.list = function(data) {
  return [
    {
      id: '1',
      name: 'Contribuidor 1',
      email: 'teste@teste.com'
    },
    {
      id: '2',
      name: 'Contribuidor 2',
      email: 'teste@teste.com'
    },
    {
      id: '3',
      name: 'Contribuidor 3',
      email: 'teste@teste.com'
    },
    {
      id: '4',
      name: 'Contribuidor 4',
      email: 'teste@teste.com'
    },
    {
      id: '5',
      name: 'Contribuidor 5',
      email: 'teste@teste.com'
    }
  ]
  //return m.request({method: "GET", url: "http://api.catarse.me/contributions", data: data});
}

app.Contribution = Contribution;