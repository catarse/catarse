beforeAll(function(){
    BalanceTransactionMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            user_id: 1,
            credit: 0,
            debit: -604.50,
            total_amount: -604.50,
            created_at: "2015-10-22",
            source: [
                {
                    amount : -604.500,
                    event_name : "catarse_project_service_fee",
                    origin_object : {
                        id: 2,
                        references_to: "project",
                        name: "Project x"
                    }
                }
            ]
        };

        data = _.extend(data, attrs);
        return [data];
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/balance_transactions)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(BalanceTransactionMockery())
    });
});
