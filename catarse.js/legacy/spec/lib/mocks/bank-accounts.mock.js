beforeAll(function(){
    BankAccountMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            user_id: 1,
            bank_name: "Banco XX",
            bank_code:"001",
            account: "11111",
            account_digit: "1",
            account_type: "Corrente",
            agency: "1111",
            agency_digit: "x",
            owner_name: "Owner name",
            owner_document:"11.111.111/0001-11",
            created_at: "2015-10-10T00:23:59.846524",
            updated_at: "2015-10-10T00:23:59.846524"
        };

        data = _.extend(data, attrs);
        return [data];
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/bank_accounts)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(BankAccountMockery())
    });
});
