beforeAll(function(){
    GoalsMockery = function(){
        return [
            {
                description: "When I feel heavy metal",
                id: 41523,
                project_id: 41920,
                title: "Woohoo",
                value: 100
            },
            {
                description: "And I'm pins and I'm needless",
                id: 41523,
                project_id: 41920,
                title: "Woohoo 2",
                value: 200
            }
        ];
    };
    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/goals)'+'(.*)')).andReturn({
      'responseText' : JSON.stringify(GoalsMockery())
    });
});
