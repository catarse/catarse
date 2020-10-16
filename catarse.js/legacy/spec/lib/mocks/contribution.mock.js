beforeAll(function(){
    ContributionMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            id: 1,
            value: "100.0",
            reward: {
                id: 1,
                description: 'reward desc...'
            }
        };

        data = _.extend(data, attrs);
        return data;
    };
});
