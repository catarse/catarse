import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import models from '../models';
import userVM from '../vms/user-vm';
import h from '../h';
import { catarse } from '../api';

const I18nScope = _.partial(h.i18nScope, 'users.balance');

const adminUserBalanceTransactionsList = {
    oninit: function(vnode) {
        const userBalance = prop({}),
            transactionsListVM = catarse.paginationVM(
                  models.balanceTransaction,
                  'created_at.desc',
                  { Prefer: 'count=exact' }
              ),
            loadNextPage = () => transactionsListVM.nextPage().then(_ => m.redraw());

        models.balanceTransaction.pageSize(2);
        userVM.getUserBalance(vnode.attrs.user_id).then(_.compose(userBalance, _.first));
        transactionsListVM.firstPage({ user_id: `eq.${vnode.attrs.user_id}` });

        vnode.state = {
            userBalance,
            transactionsListVM,
            loadNextPage
        };
    },
    view: function({state, attrs}) {
        const collection = state.transactionsListVM.collection(),
            userBalance = state.userBalance() || { amount: 0 };

        return m((attrs.wrapperClass || '.w-col.w-col-8'), [
            m('.fontsize-smaller.fontweight-semibold.lineheight-tighter.u-marginbottom-20',
              window.I18n.t('totals_transactions_title', I18nScope({
                  value: h.formatNumber(userBalance.amount, 2, 3)
              }))),
            _.map(collection, (item, intex) => m('.divider.fontsize-smallest.lineheight-looser', [
                m('.w-row.fontweight-semibold', [
                    m('.w-col.w-col-2', [
                        m('.fontcolor-secondary', h.momentify(item.created_at))
                    ]),
                    m('.w-col.w-col-6', [
                        window.I18n.t('day_balance', I18nScope())
                    ]),
                    m('.w-col.w-col-2', m.trust('&nbsp;')),
                    m('.w-col.w-col-2', [
                        m('span', window.I18n.t('shared.currency', {
                            amount: h.formatNumber(item.total_amount, 2, 3) }))
                    ]),
                ]),
                m('.w-row', [
                    _.map(item.source, (source, index) => {
                        if (source) {
                            const negativeV = source.amount < 0;
                            return m('.divider.fontsize-smallest.lineheight-looser.w-row', [
                                m('.w-col.w-col-2', []),
                                m('.w-col.w-col-6', [
                                    m('div', window.I18n.t(`event_names.${source.event_name}`, I18nScope({
                                        service_fee: source.origin_objects.service_fee ? (source.origin_objects.service_fee * 100.0) : '',
                                        project_name: source.origin_objects.project_name,
                                        contributitor_name: source.origin_objects.contributor_name
                                    })))
                                ]),
                                m('.w-col.w-col-2', [
                                    m((negativeV ? '.text-error' : '.text-success'), [
                                        negativeV ? '- ' : '+ ',
                                        window.I18n.t('shared.currency', {
                                            amount: h.formatNumber(Math.abs(source.amount), 2, 3)
                                        })
                                    ])
                                ])
                            ]);
                        } else {
                            return '';
                        }
                    })
                ])
            ])),


            m('.w-row', [
                (
                    state.transactionsListVM.isLastPage() ? 
                        '' 
                    :
                        m('.w-col.w-col-3.w-col-push-4', [
                            state.transactionsListVM.isLoading() ?
                            h.loader() :
                            m('button#load-more.btn.btn-terciary', {
                                onclick: state.loadNextPage
                            }, window.I18n.t('shared.load_more'))
                        ])
                )
            ])
        ]);
    }
};

export default adminUserBalanceTransactionsList;
