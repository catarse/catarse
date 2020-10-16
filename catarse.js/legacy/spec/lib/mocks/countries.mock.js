beforeAll(function() {
  CountriesMockery = function(attrs) {
    var data = [
      {
        id: 74,
        name: 'Argentina'
      },
      {
        id: 36,
        name: 'Brasil'
      }
    ];

    return data;
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/countries)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(CountriesMockery())
  });
});