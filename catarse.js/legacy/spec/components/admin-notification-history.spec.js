import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import adminNotificationHistory from '../../src/c/admin-notification-history';

describe('AdminNotificationHistory', () => {
    let user, historyBox,
        ctrl, view, $output;

    beforeAll(() => {
        user = prop(UserDetailMockery(1));        
        const dataOptions = {
            user: user()[0],
            notifications: [{
                sent_at: new Date(),
                relation: 'relation',
                id: 'id',
                template_name: 'template_name',
                origin: 'origin'
            }]
        };
        $output = mq(adminNotificationHistory, dataOptions);
    });

    describe('view', () => {
        it('should render fetched notifications', () => {
            expect($output.find('.date-event').length).toEqual(1);
        });
    });
});
