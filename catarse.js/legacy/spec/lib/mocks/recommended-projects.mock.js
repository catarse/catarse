beforeAll(function(){
    RecommendedProjectsMockery = function(){
        return [
            {
                user_id: 1,
                project_id: 1,
                count: 3
            },
            {
                user_id: 1,
                project_id: 1,
                count: 3
            },
            {
                user_id: 1,
                project_id: 1,
                count: 3
            }
        ];
    };
    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/recommended_projects)'+'(.*)')).andReturn({
      'responseText' : JSON.stringify(RecommendedProjectsMockery())
    });
});
