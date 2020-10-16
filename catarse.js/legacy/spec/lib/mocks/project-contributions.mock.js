beforeAll(function(){
  ProjectContributionsMockery = function(attrs){
    var attrs = attrs || {};
    var data = {
      anonymous: false,
      project_id: 15915,
      id: 605763,
      profile_img_thumbnail: "bar_avatar",
      user_id: 455160,
      user_name: "Foo",
      value: 20,
      waiting_payment: false,
      is_owner_or_admin: false,
      total_contributed_projects: 1,
      created_at: "2015-07-31T15:13:59.072806"
    };

    data = _.extend(data, attrs);
    return [data];
  };
});




