/**
 * window.c.UserBalance component
 * Render the current user total balance and request fund action
 *
 * Example:
 * m.component(c.UserBalance, {
 *     user_id: 123,
 * })
 */
import m from 'mithril';
import _ from 'underscore';
import moment from 'moment';
import models from '../models';
import h from '../h';
import modalBox from './modal-box';
import userBalanceRequestModalContent from './user-balance-request-modal-content';

const I18nScope = _.partial(h.i18nScope, 'users.balance');

const userBalance = {
    oninit: function(vnode) {
        vnode.attrs.balanceManager.load();

        vnode.state = {
            userBalances: vnode.attrs.balanceManager.collection,
            displayModal: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        const balance = _.first(state.userBalances()) || { user_id: attrs.user_id, amount: 0 },
            positiveValue = balance.amount >= 0,
            balanceRequestModalC = [
                userBalanceRequestModalContent,
                _.extend({}, { balance }, attrs)
            ];

        return m('.w-section.section.user-balance-section', [
            (
                state.displayModal() ? 
                    m(modalBox, {
                        displayModal: state.displayModal,
                        content: balanceRequestModalC
                    }) 
                : 
                    ''
            ),
            m('.w-container', [
                m('.card.card-terciary.u-radius.w-row', [
                    m('.w-col.w-col-8.u-text-center-small-only.u-marginbottom-20', [
                        m('.fontsize-larger', [
                            window.I18n.t('totals', I18nScope()),
                            m(`span.text-${positiveValue ? 'success' : 'error'}`, `R$ ${h.formatNumber(balance.amount || 0, 2, 3)}`)
                        ])
                    ]),
                    m('.w-col.w-col-4', [
                        m(`a[class="r-fund-btn w-button btn btn-medium u-marginbottom-10 ${((balance.amount <= 0 || balance.in_period_yet || balance.has_cancelation_request) ? 'btn-inactive' : '')}"][href="javascript:void(0);"]`,
                            {
                                onclick: ((balance.amount > 0 && (_.isNull(balance.in_period_yet) || balance.in_period_yet === false) && !balance.has_cancelation_request) ? state.displayModal.toggle : 'javascript:void(0);')
                            },
                            window.I18n.t('withdraw_cta', I18nScope())
                        ),
                        m('.fontsize-smaller.fontweight-semibold',
                            balance.has_cancelation_request ? window.I18n.t('withdraw_canceling_title', I18nScope()) :
                            (balance.last_transfer_amount && balance.in_period_yet ?
                                window.I18n.t('last_withdraw_msg', I18nScope({
                                    amount: `R$ ${h.formatNumber(balance.last_transfer_amount, 2, 3)}`,
                                    date: moment(balance.last_transfer_created_at).format('MMMM')
                                }))
                                : window.I18n.t('no_withdraws_this_month', I18nScope({ month_name: moment().format('MMMM') })))
                        ),
                        m('.fontcolor-secondary.fontsize-smallest.lineheight-tight',
                          balance.has_cancelation_request ? window.I18n.t('withdraw_canceling_msg', I18nScope()) : window.I18n.t('withdraw_limits_msg', I18nScope())
                        )
                    ])
                ])
            ])
        ]);
    }
};

export default userBalance;
