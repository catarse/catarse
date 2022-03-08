beforeAll(function(){
  ProjectMockery = function(attrs){
    var attrs = attrs || {};
    var data = [_.extend({
      project_id: 6051,
      project_name: 'foo',
      headline: 'foo',
      permalink: 'foo',
      state: "online",
      online_date: "2015-07-13T10:19:40.193106-03:00",
      recommended: 'true',
      project_img: 'http://foo.com/foo.jpg',
      remaining_time: {
        unit: 'days',
        total: '10'
      },
      elapsed_time: {
        unit: 'days',
        total: '0'
      },
      expires_at: "2015-09-12T02:59:59",
      pledged: 5220.0,
      progress: 41,
      state_acronym: 'SP',
      owner_name: 'foo',
      city_name: 'bar'
    }, attrs),
    {
      "project_id":14,
      "id":14,
      "user_id":3,
      "name":"QA1AON",
      "headline":"test",
      "budget":"<p>test\n</p>",
      "goal":123124.12,
      "about_html":"<p>test\n</p>",
      "permalink":"qa1aon_4727",
      "video_embed_url":null,
      "video_url":null,
      "category_name":"Mobilidade e Transporte",
      "category_id":1,
      "original_image":null,
      "thumb_image":null,
      "small_image":null,
      "large_image":null,
      "video_cover_image":null,
      "progress":0,
      "pledged":0,
      "total_contributions":0,
      "total_contributors":0,
      "state":"successful",
      "mode":"aon",
      "state_order":"finished",
      "expires_at":"2018-07-25T20:58:39.91553",
      "zone_expires_at":"2018-07-25T17:58:39.91553",
      "online_date":"2018-08-29T19:54:29.461845",
      "zone_online_date":"2018-08-29T16:54:29.461845",
      "sent_to_analysis_at":null,
      "is_published":true,
      "is_expired":true,
      "open_for_contributions":false,
      "online_days":60,
      "remaining_time":{
        "total" : 0,
        "unit" : "seconds"
      },
      "elapsed_time":{
        "total" : 0,
        "unit" : "seconds"
      },
      "posts_count":0,
      "address":{
        "city" : "fda",
        "state_acronym" : "RS",
        "state" : "Rio Grande do Sul"
      },
      "user":{
        "id" : 3,
        "name" : "test test",
        "public_name" : "Test1"
      },
      "reminder_count":0,
      "is_owner_or_admin":true,
      "user_signed_in":true,
      "in_reminder":false,
      "total_posts":0,
      "can_request_transfer":true,
      "is_admin_role":false,
      "contributed_by_friends":false,
      "admin_tag_list":null,
      "tag_list":null,
      "city_id":4,
      "admin_notes":null,
      "service_fee":null,
      "has_cancelation_request":false,
      "can_cancel":true,
      "tracker_snippet_html":"",
      "cover_image":null,
      "common_id":"9deafb36-6d86-48d5-900c-bf3c6b7e3e54"
    },
    {
      project_id: 6012,
      project_name: 'foo',
      headline: 'foo',
      permalink: 'foo',
      state: "online",
      mode: 'sub',
      online_date: "2015-07-13T10:19:40.193106-03:00",
      recommended: 'true',
      project_img: 'http://foo.com/foo.jpg',
      remaining_time: {
        unit: 'days',
        total: '10'
      },
      elapsed_time: {
        unit: 'days',
        total: '0'
      },
      expires_at: "2015-09-12T02:59:59",
      pledged: 5220.0,
      progress: 41,
      state_acronym: 'SP',
      owner_name: 'foo',
      city_name: 'bar'
    }];

    return data;
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/projects)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(ProjectMockery())
  });


  ProjectsGenerator = function(numberOfProjects, overrides, url) {

    const projectBase = {
      project_id: 5,
      category_id: 1,
      project_name: "TEST1",
      headline: "qwdqwd",
      permalink: url,
      mode: "aon",
      state: "online",
      state_order: "published",
      online_date: "2020-01-09T18:57:32.485809",
      recommended: false,
      project_img: "something.jpg",
      remaining_time: {
        total: 15,
        unit: "days"
      },
      expires_at: "2020-02-29T02:59:59.999999",
      pledged: 0,
      progress: 0,
      state_acronym: "LK",
      owner_name: "Owner Name",
      city_name: "City Name",
      full_text_index: null,
      open_for_contributions: true,
      elapsed_time: {
        total: 34,
        unit: "days"
      },
      score: null,
      contributed_by_friends: false,
      project_user_id: 5,
      video_embed_url: null,
      updated_at: "2020-01-09T21:57:32.977841",
      owner_public_name: "Public Owner Name",
      zone_expires_at: "2020-02-28T23:59:59.999999",
      common_id: "a60eec2e-dbe0-4efb-876c-e8c5ec0c8adc",
      is_adult_content: false,
      content_rating: 1,
      active_saved_projects: true
    };

    const projects = [];
    let project_id = 1;
    for (let i = 0; i < numberOfProjects; i++ ) {
      projects.push(Object.assign({}, projectBase, {...overrides, project_id}));
      project_id++;
    }

    return projects;
  };

  jasmine.Ajax.stubRequest(new RegExp(`(${apiPrefix}/rpc/project_search).*`)).andReturn({
    'responseText' : JSON.stringify(ProjectsGenerator(5, {project_name: 'SEARCH'}))
  });

});
