beforeAll(function() {
    UserBalanceWithdrawHistoryItemMock = function(attrs) {

        var userBalanceTransfersRequests = [
            {
                "user_id":3,
                "amount":1000,
                "funding_estimated_date":"2018-09-17T20:12:51.046076",
                "status":"pending",
                "transferred_at":null,
                "transferred_date":null,
                "requested_in":"2018-09-03T20:12:51.046076",
                "user_name":"test test",
                "bank_name":"Itaú Unibanco S.A.",
                "agency":"1234",
                "agency_digit":"",
                "account":"12345",
                "account_digit":"1",
                "account_type":"conta_corrente",
                "document_type":"cpf",
                "document_number":"83955563146"
            },                
            {
                "user_id":3,
                "amount":1000,
                "funding_estimated_date":"2018-09-17T20:12:51.046076",
                "status":"rejected",
                "transferred_at":null,
                "transferred_date":null,
                "requested_in":"2018-09-03T20:12:51.046076",
                "user_name":"test test",
                "bank_name":"Itaú Unibanco S.A.",
                "agency":"1234",
                "agency_digit":"",
                "account":"12345",
                "account_digit":"1",
                "account_type":"conta_corrente",
                "document_type":"cpf",
                "document_number":"83955563146"
            },    
            {
                "user_id":3,
                "amount":1000,
                "funding_estimated_date":"2018-09-17T20:12:51.046076",
                "status":"transferred",
                "transferred_at":"2018-09-17T20:12:51.046076",
                "transferred_date":"2018-09-17",
                "requested_in":"2018-09-03T20:12:51.046076",
                "user_name":"test test",
                "bank_name":"Itaú Unibanco S.A.",
                "agency":"1234",
                "agency_digit":"",
                "account":"12345",
                "account_digit":"1",
                "account_type":"conta_corrente",
                "document_type":"cpf",
                "document_number":"83955563146"
            }
        ];

        return userBalanceTransfersRequests;
    }
});