/**
 * window.c.userBalanceMain component
 * A root component to show user balance and transactions
 *
 * Example:
 * To mount this component just create a DOM element like:
 * <div data-mithril="UsersBalance" data-parameters="{'user_id': 10}">
 */
import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import models from '../models';
import userBalance from './user-balance';
import userBalanceTransactions from './user-balance-transactions';
import userBalanceWithdrawHistory from './user-balance-withdraw-history';
import userBalanceTransactionsListVM from '../vms/user-balance-transactions-list-vm';
import userBalanceTransfersListVM from '../vms/user-balance-transfers-list-vm';

const userBalanceMain = {
    oninit: function(vnode) {
        const userIdVM = catarse.filtersVM({ user_id: 'eq' });

        userIdVM.user_id(vnode.attrs.user_id);

        // Handles with user balance request data
        const balanceManager = (() => {
                const collection = prop([{ amount: 0, user_id: vnode.attrs.user_id }]),
                    load = () => {
                        return models.balance
                            .getRowWithToken(userIdVM.parameters())
                            .then(collection)
                            .then(_ => m.redraw());
                    };

                return {
                    collection,
                    load
                };
            })(),

            // Handles with user balance transactions list data
            userBalanceTransactionsList = userBalanceTransactionsListVM(userIdVM.parameters()),
            userBalanceTransfersList = userBalanceTransfersListVM(userIdVM.parameters()),

            // Handles with bank account to check
            bankAccountManager = (() => {
                const collection = prop([]),
                    loader = (() => catarse.loaderWithToken(
                                models.bankAccount.getRowOptions(
                                    userIdVM.parameters())))(),
                    load = () => {
                        return loader
                            .load()
                            .then(collection)
                            .then(() => m.redraw());
                    };

                return {
                    collection,
                    load,
                    loader
                };
            })();

        vnode.state = {
            bankAccountManager,
            balanceManager,
            userBalanceTransactionsList,
            userBalanceTransfersList
        };
    },
    view: function({state, attrs}) {
        const opts = _.extend({}, attrs, state);
        return m('#balance-area', [
            m(userBalance, opts),
            m(userBalanceWithdrawHistory, opts),
            m('.divider'),
            m(userBalanceTransactions, opts),
            m('.u-marginbottom-40'),
            m('.w-section.section.card-terciary.before-footer')
        ]);
    }
};

export default userBalanceMain;
