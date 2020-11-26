beforeAll(function(){
  ProjectContributionsPerLocationMockery = function(attrs){
    var attrs = attrs || {};
    var data = {
      project_id: 1234,
      source: [
        {
          state_acronym: 'PB',
          state_name: 'Paraíba',
          total_contributions: 2,
          total_contributed: 550.0,
          total_on_percentage: 3.4424485197471365
        }, {
          state_acronym: 'PR',
          state_name : 'Paraná',
          total_contributions: 1,
          total_contributed: 100.0,
          total_on_percentage: 0.62589973086311572886
        }
      ]
    };

    data = _.extend(data, attrs);
    return [data];
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/project_contributions_per_location)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(ProjectContributionsPerLocationMockery())
  });
});



