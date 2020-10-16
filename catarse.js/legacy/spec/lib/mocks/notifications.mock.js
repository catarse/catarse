beforeAll(function() {
  NotificationMockery = function(attrs) {
    var attrs = attrs || {};
    var data = {
        created_at: "2015-07-11T22:31:35.18576",
        deliver_at: null,
        sent_at: "2015-07-12T00:18:32.182137",
        template_name: "new_terms",
        user_id: 334765
    };

    data = _.extend(data, attrs);
    return [data];
  };

  jasmine.Ajax.stubRequest(new RegExp('('+apiPrefix + '\/notifications)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(NotificationMockery())
  });
});
