beforeAll(function(){
    PostEntryMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            clicked_to_delete: false,
            post: {
                id: 1231,
                title: 'THIS IS THE TITLE',
                created_at: '2018-10-22 10:10:22',
                delivered_count: 0,
                open_count: 10
            },
            project: {
                project_id: 22
            },
            showOpenPercentage: '20',
            deletePost: () => () => {
                data.clicked_to_delete = true
            },
            destinatedTo: 'THIS ARE THE DESTINATIONS'
        };

        data = _.extend(data, attrs);
        return [data];
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/project_posts_details)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(PostEntryMockery())
    });
});