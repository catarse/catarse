beforeAll(function() {
  RewardDetailsMockery = function(attrs) {
    var attrs = attrs || {};
    var data = {
      id: 25935,
      project_id: 6140,
      description: "reward_descriptiom",
      minimum_value: 20,
      maximum_contributions: null,
      deliver_at: "2014-12-01T02:00:00",
      updated_at: "2014-08-13T16:08:07.67877",
      paid_count: 82,
      waiting_payment_count: 0
    };

    data = _.extend(data, attrs);
    return [data];
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/reward_details)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(RewardDetailsMockery())
  });
});
