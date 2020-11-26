beforeAll(function(){
    BalanceMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            user_id: 10,
            amount: 205
        };

        data = _.extend(data, attrs);
        return [data];
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/balances)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(BalanceMockery())
    });
});
