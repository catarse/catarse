beforeAll(function() {

    AdminSubscriptionNotifications = function() {
        var data = [{"id":"11ba1c66-702f-416c-ac17-75896d254e05","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:34.55509","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"a9083409-ca9e-4fa1-9bb7-be764a91029e","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:34.307857","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"04530556-198c-4c5e-974e-3bc0f1369a1f","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:34.077013","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"7d53c1a4-b63f-43e1-a758-00f7c14ece7e","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:33.849822","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"1fc66969-0484-43ae-bdd3-870ce537826f","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:33.629352","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"d1a0e62a-d085-460c-9867-c0f9c801c7ae","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:33.430653","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"4f79ce2d-d9d4-45f1-8791-1b9dc95d81ef","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:33.211732","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"c471d4d7-e4e7-4777-88d9-05df64cbebeb","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:32.844142","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"6c743bbd-9d09-46ad-9c56-0f1af238798d","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-16T13:16:32.266234","label":"canceling_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}, 
                    {"id":"1e6bfab8-51a5-4610-8466-c1eb10177286","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-11T19:26:45.863684","label":"inactive_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"},
                    {"id":"1e6bfab8-51a5-4610-8466-c1eb10177286","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-11T19:26:45.863684","label":"inactive_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"},
                    {"id":"1e6bfab8-51a5-4610-8466-c1eb10177286","user_id":"bdb1a3d1-7d02-4767-baad-18abdf3be236","created_at":"2018-07-11T19:26:45.863684","label":"inactive_subscription","project_id":"8f898112-5d69-46b4-aee0-e901287c3575"}];

    
        return data;
    };

    jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/user_notifications)'+'(.*)')).andReturn({
        'responseText' : JSON.stringify(AdminSubscriptionNotifications())
    });
})