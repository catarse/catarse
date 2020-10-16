import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import { catarse } from '../api';
import models from '../models';
import userBalanceWithdrawHistoryItemRequest from './user-balance-withdraw-history-item-request';

import loadMoreBtn from './load-more-btn';

const I18nScope = _.partial(h.i18nScope, 'users.balance');
const I18nScopeTransfer = _.partial(h.i18nScope, 'users.balance.transfer_labels');
const I18nScopeBank = _.partial(h.i18nScope, 'users.balance.bank');

const userBalanceWithdrawHistory = {
    oninit: function (vnode) {

        const explitInArraysOf3 = (collection) => {
            const array = [];
            let partArray = []; 
            let i;

            if (collection.length > 3) {

                for (i = 0; i < collection.length; i++) {
    
                    partArray.push(collection[i]);

                    if (partArray.length == 3) {
                        array.push(partArray);
                        partArray = [];
                    }

                }
                
                if (partArray.length != 3 && partArray.length != 0)
                    array.push(partArray);
            }
            else {
                array.push(collection);
            }
            
            return array;
        };

        vnode.state = {
            explitInArraysOf3
        };
    },
    view: function ({state, attrs}) {

        const userBalanceTransfersList = attrs.userBalanceTransfersList;

        return m('div',
            m('.w-container', [
                m('.u-marginbottom-20',
                    m('.fontsize-base.fontweight-semibold', I18n.t('withdraw_history_group', I18nScope()))
                ),
                (
                    _.map(state.explitInArraysOf3(userBalanceTransfersList.collection()), 
                        (transferList) => m('.u-marginbottom-30.w-row',  
                            _.map(transferList, 
                                (transfer, index) => m(userBalanceWithdrawHistoryItemRequest, { transfer, index }))
                    ))
                ),
                (
                    userBalanceTransfersList.isLoading() ? 
                        h.loader() 
                    :
                        (
                            userBalanceTransfersList.isLastPage() ? 
                                '' 
                            : 
                                m('.u-margintop-40.u-marginbottom-80.w-row', [
                                    m('.w-col.w-col-5'),
                                    m('.w-col.w-col-2',
                                        m('a.btn.btn-medium.btn-terciary.w-button[href=\'javascript:void(0);\']', {
                                            onclick: userBalanceTransfersList.nextPage
                                        }, 'Carregar mais')
                                    ),
                                    m('.w-col.w-col-5')
                                ])
                        )
                )
            ])
        );
    }
}

export default userBalanceWithdrawHistory;
