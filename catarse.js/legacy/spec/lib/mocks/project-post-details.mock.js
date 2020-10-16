beforeAll(function() {
  ProjectPostDetailsMockery = function(attrs) {
    var attrs = attrs || {};
    var data = {
      id: 15585,
      project_id: 15915,
      is_owner_or_admin: false,
      exclusive: false,
      title: "foo title",
      comment_html: "foo comment html",
      created_at: "2015-08-17T18:54:53.380678"
    };

    data = _.extend(data, attrs);
    return [data];
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/project_posts_details)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(ProjectPostDetailsMockery())
  });
});
