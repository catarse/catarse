beforeAll(function(){
  StatisticMockery = function(attrs){
    var attrs = attrs || {};
    var data = {
      total_users: 460603,
      total_contributions: 354003,
      total_contributors: 229701,
      total_contributed: 33353415.125,
      total_projects: 7009,
      total_projects_success: 1916,
      total_projects_online: 205
    };

    data = _.extend(data, attrs);
    return [data];
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/statistics)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(StatisticMockery())
  });
});



