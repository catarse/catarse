beforeAll(function(){
  TeamTotalMockery = function(attrs){
    var attrs = attrs || {};
    var data = {
      member_count: 25,
      countries: ['Brasil', "Canada", 'Australia'],
      total_contributed_projects: 10,
      total_cities: 11,
      total_amount: 1500
    };

    data = _.extend(data, attrs);
    return [data];
  };

  TeamMembersMockery = function(j,attrs){
    var attrs = attrs || {},
        members = [],
        i;

    for(i = 0; i < j; i++){
      var data = {
        name: "Foobar",
        img: "img_url",
        id: i,
        total_contributed_projects: 20,
        total_amount_contributed: 20.40
      };
      data = _.extend(data, attrs);
      members.push(data);
    }
    return members;
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/team_totals)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(TeamTotalMockery())
  });

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/team_members)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(TeamMembersMockery(10))
  });
});

