beforeAll(function() {
  CreditCardMockery = function(attrs) {
    var data = [
      {
        "id": 1,
        "user_id": 1,
        "last_digits":"0001",
        "card_brand":"visa",
        "subscription_id": null,
        "created_at":"2016-09-22T23:00:12.750-03:00",
        "updated_at":"2016-09-22T23:00:12.750-03:00",
        "card_key":"card_cardkeycardkey"
      }
    ];

    return data;
  };

  jasmine.Ajax.stubRequest('/users/1/credit_cards').andReturn({
    'responseText' : JSON.stringify(CreditCardMockery())
  });
});
