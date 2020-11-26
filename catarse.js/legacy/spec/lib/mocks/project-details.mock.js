beforeAll(function(){
  ProjectDetailsMockery = function(attrs){
    var attrs = attrs || {};
    var data = {
      name: "Histórias de Verdade",
      headline: "Historinhas bíblicas para crianças",
      project_id: 6051,
      progress: 41,
      pledged: 5220.0,
      total_contributions: 160,
      state: "online",
      expires_at: "2015-09-12T02:59:59",
      online_date: "2015-07-13T10:19:40.193106-03:00",
      sent_to_analysis_at: "2014-07-01T23:01:05.640456",
      is_published: true,
      is_owner_or_admin: true,
      is_expired: false,
      open_for_contributions: true,
      reminder_count: 23,
      remaining_time: {total: 22, unit: "days"},
      elapsed_time: {total: 20, unit: 'days'},
      mode: 'aon',
      user: {id: 123, name: "Lorem ipsum"},
      video_embed_url: "//www.youtube.com/embed/6Klp834jk3M",
      video_url: "https://youtu.be/6Klp834jk3M",
      address: {
        city: "Parnamirim",
        state_acronym: "RN",
        state: "RN"
      },
      about_html: 'Lorem ipsum'
    };

    data = _.extend(data, attrs);
    return [data];
  };

  jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/project_details)'+'(.*)')).andReturn({
    'responseText' : JSON.stringify(ProjectDetailsMockery())
  });
});


