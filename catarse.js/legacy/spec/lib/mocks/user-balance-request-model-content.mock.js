beforeAll(function () {
    const user_id = 1000;

    const attrs = {
        balance: {
            user_id,
            amount: 10000
        },
        rails_errors: [],
        user: {
            id: user_id,
            common_id: null,
            name: 'aasdasd',
            deactivated_at: null,
            profile_img_thumbnail: null,
            facebook_link: null,
            twitter_username: null,
            address: {
                id: 2765,
                country_id: 2595,
                state_id: null,
                address_street: 'asdasd',
                address_number: null,
                address_complement: null,
                address_neighbourhood: null,
                address_city: 'asdasd',
                address_zip_code: 'asdasd',
                phone_number: null,
                created_at: '2020-04-17T15:00:12.338237',
                updated_at: '2020-04-17T15:00:12.338237',
                address_state: 'AC',
                common_id: null
            },
            email: 'some@email.com',
            total_contributed_projects: 0,
            total_published_projects: 0,
            links: null,
            follows_count: 0,
            followers_count: 0,
            owner_document: '123.132.123-12',
            profile_cover_image: null,
            created_at: '2020-04-09T13:05:07.276391',
            about_html: null,
            is_owner_or_admin: false,
            newsletter: false,
            subscribed_to_project_posts: true,
            subscribed_to_new_followers: true,
            subscribed_to_friends_contributions: true,
            is_admin: false,
            permalink: null,
            email_active: true,
            public_name: 'aasdasd',
            following_this_user: false,
            state_inscription: '',
            birth_date: '2000-01-01',
            account_type: 'pf',
            is_admin_role: true,
            mail_marketing_lists: [
                {
                    user_marketing_list_id: null,
                    marketing_list: null
                }
            ]
        }
    };

    UserBalanceRequestModalContentMock = function () {
        return attrs;
    };

    UserBalanceRequestModalContentUserBankAccountMock = function () {
        return {
            user_id,
            bank_name: 'MY BANK',
            bank_code: '999',
            account: '12345',
            account_digit: '1',
            agency: '6666',
            agency_digit: '',
            owner_name: 'aasdasd',
            owner_document: '023.342.610-84',
            created_at: '2020-04-17T18:31:54.576819',
            updated_at: '2020-04-17T19:14:35.581276',
            bank_account_id: 2092,
            bank_id: 131,
            account_type: 'conta_corrente'
        };
    };

    // Balances stub
    // catarse api /balances?user_id=eq.1000
    jasmine.Ajax.stubRequest(new RegExp('(' + apiPrefix + `\/balances?user_id=eq.${user_id})` + '(.*)')).andReturn({
        responseText: JSON.stringify([
            {
                user_id: 1000,
                amount: 4000,
                last_transfer_amount: -1000,
                last_transfer_created_at: null,
                in_period_yet: null,
                has_cancelation_request: false
            }
        ])
    });
});
