beforeAll(function(){
    ContributorMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            project_id: 15915,
            id: 605763,
            user_id: 455160,
            data: {
                profile_img_thumbnail: "bar_avatar",
                name: "Foo",
                city: 'Lorem',
                state: 'KJ',
                total_contributed_projects: 1,
                total_published_projects: 1
            }
        };

        data = _.extend(data, attrs);
        return [data];
    };
});
