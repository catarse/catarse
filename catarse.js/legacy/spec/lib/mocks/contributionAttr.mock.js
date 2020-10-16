beforeAll(function(){
    ContributionAttrMockery = function(attrs, payment){
        var attrs = attrs || {};
        var data = {
            contribution_id: 1,
            value: 10,
            project: {
                category: 'test',
                user_thumb: 'test',
                permalink: 'test',
                total_contributions: 'test',
                service_fee: 'test',
                name: 'test'
            },
            reward: {
                reward_id: 1,
                minimum_value: 10
            },
            contribution_email: 'test@test.test',
            slip_url: payment === 'slip' ? 'http://boleto.url' : null
        };

        data = _.extend(data, attrs);
        return data;
    };
});
