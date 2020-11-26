import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import adminTransactionHistory from '../../src/c/admin-transaction-history';

describe('adminTransactionHistory', () => {
    let c = window.c,
        contribution, historyBox,
        ctrl, view, $output;

    beforeAll(() => {
        contribution = prop(ContributionDetailMockery(1));
        ctrl = adminTransactionHistory.oninit({attrs: {contribution: contribution()[0]}});
        $output = mq(adminTransactionHistory, {
            contribution: contribution()[0]
        });
    });

    describe('controller', () => {
        it('should have orderedEvents', () => {
            expect(ctrl.orderedEvents.length).toEqual(2);
        });

        it('should have formated the date on orderedEvents', () => {
            expect(ctrl.orderedEvents[0].date).toEqual('15/01/2015, 17:25');
        });
    });

    describe('view', () => {
        it('should render fetched orderedEvents', () => {
            expect($output.find('.date-event').length).toEqual(2);
        });
    });
});
