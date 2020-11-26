beforeAll(function(){
    BalanceTransferMockery = function(attrs){
        var attrs = attrs || {};
        var data = [_.extend({
            amount: 205,
            created_at: "2015-12-23T23:29:33.466779",
            id: 1,
            state: "pending",
            transfer_id: null,
            user_id: 1
        }, attrs),
        {
            "id":6,
            "user_id":3,
            "project_id":14,
            "amount":1000.0,
            "transfer_id":"167028",
            "created_at":"2018-09-04T19:38:19.758014",
            "transfer_limit_date":"2018-09-18T19:38:19.758014",
            "state":"processing",
            "last_transition_metadata":	{
                "transfer_data":{
                    "amount":100000,
                    "object":"transfer",
                    "id":167028,
                    "type":"ted",
                    "status":"pending_transfer",
                    "source_type":"recipient",
                    "source_id":"re_ci76hy9k000gsdw16ab7yyrgr",
                    "target_type":"bank_account",
                    "target_id":"17898486",
                    "fee":367,
                    "funding_date":null,
                    "funding_estimated_date":"2018-09-12T03:00:00.000Z",
                    "transaction_id":null,
                    "date_created":"2018-09-11T20:36:31.682Z",
                    "metadata":{},
                    "bank_account":{
                        "object":"bank_account",
                        "id":17898486,
                        "bank_code":"341",
                        "agencia":"1234",
                        "agencia_dv":null,
                        "conta":"12345",
                        "conta_dv":"1",
                        "type":"conta_corrente",
                        "document_type":"cpf",
                        "document_number":"83955563146",
                        "legal_name":"test test",
                        "charge_transfer_fees":true,
                        "date_created":"2018-09-11T20:36:30.828Z"
                    }
                }
            },
            "transferred_at":"2018-09-11T17:36:31",
            "transferred_date":"2018-09-11",
            "created_date":"2018-09-04",
            "full_text_index":"'167028':34 '3':33 'balanc':5C,8C,11C,14C,17C,20C,23C,28C 'error':10C,16C,22C 'local':26C,31C 'manipul':27C,32C 'request':7C,13C,19C,25C,30C 'test':1A,2A 'test1':3A 'test1@gmail.com':4B 'transfer':6C,9C,12C,15C,18C,21C,24C,29C",
            "user_name":"test test",
            "user_public_name":"Test1",
            "user_email":"test1@gmail.com",
            "admin_notes":null
        }];

        return data;
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/balance_transfers)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(BalanceTransferMockery())
    });
});
