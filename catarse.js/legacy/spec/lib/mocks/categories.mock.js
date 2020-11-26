beforeAll(function(){
    CategoryMockery = function(attrs){
        var attrs = attrs || {};
        var data = {
            id: 1,
            name: 'foo',
            online_projects: 2,
            following: true
        };

        data = _.extend(data, attrs);
        return [data];
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/categories)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(CategoryMockery())
    });
});



