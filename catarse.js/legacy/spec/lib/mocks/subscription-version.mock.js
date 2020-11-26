beforeAll(function(){
    SubscriptionVersionMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            "id":"fa800670-4fe9-4da2-b934-dfe58001c107",
            "project_id":"a69f95bb-e7b9-441d-aac7-c14dd86cce99",
            "credit_card_id":null,
            "paid_count":1,
            "total_paid":1000,
            "status":"active",
            "paid_at":null,
            "next_charge_at":"2018-05-27T17:42:51.16365",
            "checkout_data":{
                "amount": "1500",
                "customer": {
                    "name": "asudhiaushd", 
                    "email": "asd@asd",
                    "phone": {
                        "ddd": "12",
                        "ddi": "23", 
                        "number": "123456789"
                    }, 
                    "address": {
                        "city": "Bleh",
                        "state": "RR",
                        "street": "ASD asdasdas asd",
                        "country": "Cluscy",
                        "zipcode": "99999-999",
                        "neighborhood": "FDA",
                        "complementary": "321",
                        "street_number": "123"
                    },
                    "document_number": "12345678912"
                },
                "anonymous": false,
                "payment_method": "boleto",
                "is_international": false,
                "credit_card_owner_document": null
            },
            "created_at":"2018-04-27T17:42:51.16365",
            "user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236",
            "reward_id":"fe593bda-d9ba-4f06-97e6-512ca387553e",
            "amount":1000,
            "project_external_id":"4",
            "reward_external_id":"5",
            "user_external_id":"2",
            "payment_method":"boleto",
            "last_payment_id":"95d8b23f-a088-4539-8803-35604ab53ed9",
            "last_paid_payment_id":"95d8b23f-a088-4539-8803-35604ab53ed9",
            "last_paid_payment_created_at":"2018-04-27T17:42:51.16365",
            "user_email":"asd@asd",
            "current_paid_subscription":{
                "amount": 1000,
                "customer": {
                    "name": "Bleh",
                    "email": "asd@asd",
                    "phone": {
                        "ddd": "12",
                        "ddi": "23", 
                        "number": "123456789"
                    }, 
                    "address": {
                        "city": "Blah",
                        "state": "RR",
                        "street": "Asd asdasd dd",
                        "country": "Cluscy",
                        "zipcode": "99999-999",
                        "neighborhood": "FDA",
                        "complementary": "321",
                        "street_number": "123"
                    }, 
                    "document_number": "12345678912"
                },
                "anonymous": false,
                "current_ip": "127.0.0.1",
                "payment_method": "credit_card",
                "is_international": false
            },
            "current_reward_data":{
                "title": "Notas",
                "metadata": null,
                "row_order": 4194304,
                "current_ip": "127.0.0.1",
                "deliver_at": "2018-04-01",
                "description": "Mais notas",
                "minimum_value": 1000.0,
                "shipping_options": "free",
                "maximum_contributions": 0
            },
            "current_reward_id":"252f4e28-7869-49cf-88e7-f123706b7291",
            "last_payment_data": {
                "id":"95d8b23f-a088-4539-8803-35604ab53ed9",
                "refused_at": null,
                "next_retry_at": null,
                "status": 'paid',
                "created_at":"2018-04-27T17:42:51.16365",
                "payment_method": "boleto"
            },
            "last_paid_payment_data": {
                "id":"95d8b23f-a088-4539-8803-35604ab53ed9",
                "status": 'paid',
                "created_at":"2018-04-27T17:42:51.16365",
                "payment_method": "boleto"
            }
        };
        data = _.extend(data, attrs);
        return data;
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/subscriptions)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(SubscriptionVersionMockery())
    });
});
