import mq from 'mithril-query'
import m from 'mithril'
import _ from 'underscore'
import h from '../../../../../../src/h'
import { UserBalanceWithdrawHistoryItemRequest } from '../../../../../../src/root/users/edit/#balance/user-balance-withdraw-history/user-balance-withdraw-history-item-request';


describe('UserBalanceWithdrawHistoryItem', function() {

    let $cardPending, $cardRejected, $cardTransferred, transfers, $cardPendingComponent;

    describe('view', function() {

        beforeAll(function() {
            
            transfers = UserBalanceWithdrawHistoryItemMock();
            let transfer, index;

            index = 0;
            transfer = transfers[index];
            $cardPendingComponent = m(UserBalanceWithdrawHistoryItemRequest, { transfer });
            $cardPending = mq($cardPendingComponent);

            index = 1;
            transfer = transfers[index];

            $cardRejected = mq(m(UserBalanceWithdrawHistoryItemRequest, { transfer }));

            index = 2;
            transfer = transfers[index];

            $cardTransferred = mq(m(UserBalanceWithdrawHistoryItemRequest, { transfer }));
            
        });

        it('Should show pending card', function() {
            expect($cardPending.contains(h.momentify(transfers[0].funding_estimated_date, 'DD/MM/YYYY'))).toBeTrue();
        });

        it('Should show rejected card', function() {
            expect($cardRejected.find('span.fa.fa-exclamation-circle').length).toEqual(1);
        });

        it('Should show transferred card', function() {
            expect($cardTransferred.contains(h.momentify(transfers[2].transferred_at, 'DD/MM/YYYY'))).toBeTrue();
        });
    });
});
