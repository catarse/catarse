beforeAll(function(){
    PaymentInfoMockery = function(attrs){
        var attrs = attrs || {};
        var ONE_DAY = 24 * 60 * 60 * 1000;
        var yesterday = new Date(Date.now() - ONE_DAY);

        var expiredSlipData = {
            "id" : "ec280685-8446-4867-8457-ddea8e6ba69f", 
            "subscription_id" : "2ef45e5f-621a-4b3c-bc80-c0a0a440c691", 
            "user_id" : "bdb1a3d1-7d02-4767-baad-18abdf3be236", 
            "status" : "pending", 
            "gateway_errors" : null, 
            "created_at" : "2018-06-20T18:48:43.196522", 
            "boleto_url" : "https://pagar.me", 
            "boleto_barcode" : null, 
            "boleto_expiration_date" : yesterday.toISOString().slice(0, 10) + " 19:02:03.317787+00",
            "gateway_refuse_reason" : null, 
            "gateway_status_reason" : null, 
            "card_brand" : null, 
            "card_country" : null, 
            "card_first_digits" : null, 
            "card_last_digits" : null, 
            "gateway_payment_method" : null
        };
        expiredSlipData = _.extend(expiredSlipData, attrs);
        return expiredSlipData;
    };

    jasmine.Ajax.stubRequest(new RegExp("("+"https://payment.common.io" + '\/rpc\/payment_info)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(PaymentInfoMockery())
    });

});
