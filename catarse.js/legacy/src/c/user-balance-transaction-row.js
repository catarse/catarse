import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'users.balance');

const userBalanceTrasactionRow = {
    oninit: function(vnode) {
        const expanded = h.toggleProp(false, true);

        if (vnode.attrs.index == 0) {
            expanded.toggle();
        }

        vnode.state = {
            expanded
        };
    },
    view: function({state, attrs}) {
        const item = attrs.item,
            createdAt = h.momentFromString(item.created_at, 'YYYY-MM-DD');

        item.source = _.compact(item.source);
        
        return m(`div[class='balance-card ${(state.expanded() ? 'card-detailed-open' : '')}']`,
                m('.w-clearfix.card.card-clickable', [
                    m('.w-row', [
                        m('.w-col.w-col-2.w-col-tiny-2', [
                            m('.fontsize-small.lineheight-tightest', createdAt.format('D MMM')),
                            m('.fontsize-smallest.fontcolor-terciary', createdAt.format('YYYY'))
                        ]),
                        m('.w-col.w-col-10.w-col-tiny-10', [
                            m('.w-row', [
                                m('.w-col.w-col-4', [
                                    m('div', [
                                        m('span.fontsize-smaller.fontcolor-secondary', window.I18n.t('debit', I18nScope())),
                                        m.trust('&nbsp;'),
                                        m('span.fontsize-base.text-error', `R$ ${h.formatNumber(Math.abs(item.debit), 2, 3)}`)
                                    ])
                                ]),
                                m('.w-col.w-col-4', [
                                    m('div', [
                                        m('span.fontsize-smaller.fontcolor-secondary', window.I18n.t('credit', I18nScope())),
                                        m.trust('&nbsp;'),
                                        m('span.fontsize-base.text-success', `R$ ${h.formatNumber(item.credit, 2, 3)}`)
                                    ])
                                ]),
                                m('.w-col.w-col-4', [
                                    m('div', [
                                        m('span.fontsize-smaller.fontcolor-secondary', window.I18n.t('totals', I18nScope())),
                                        m.trust('&nbsp;'),
                                        m('span.fontsize-base', `R$ ${h.formatNumber(item.total_amount, 2, 3)}`)
                                    ])
                                ])
                            ])
                        ])
                    ]),
                    m(`a.w-inline-block.arrow-admin.${(state.expanded() ? 'arrow-admin-opened' : '')}.fa.fa-chevron-down.fontcolor-secondary[href="javascript:(void(0));"]`, { 
                        onclick: () => state.expanded.toggle()
                    })
                ]),
                (
                    state.expanded() ? 
                        (
                            m('.card', _.map(item.source, (transaction) => {
                                const pos = transaction.amount >= 0;
                                const event_data = {
                                    subscription_reward_label: transaction.origin_objects.subscription_reward_label || '',
                                    subscriber_name: transaction.origin_objects.subscriber_name,
                                    service_fee: transaction.origin_objects.service_fee ? (transaction.origin_objects.service_fee * 100.0) : '',
                                    project_name: transaction.origin_objects.project_name,
                                    contributitor_name: transaction.origin_objects.contributor_name,
                                    from_user_name: transaction.origin_objects.from_user_name,
                                    to_user_name: transaction.origin_objects.to_user_name,
                                };
    
                                return m('div', [
                                    m('.w-row.fontsize-small.u-marginbottom-10', [
                                        m('.w-col.w-col-2', [
                                            m(`.text-${(pos ? 'success' : 'error')}`, `${pos ? '+' : '-'} R$ ${h.formatNumber(Math.abs(transaction.amount), 2, 3)}`)
                                        ]),
                                        m('.w-col.w-col-10', [
                                            (transaction.event_name === 'balance_expired'
                                                ? m('div', m.trust(window.I18n.t(`event_names.${transaction.event_name}`, I18nScope(event_data))))
                                                : m('div', window.I18n.t(`event_names.${transaction.event_name}`, I18nScope(event_data)))
                                            )
                                        ])
                                    ]),
                                    m('.divider.u-marginbottom-10')
                                ]);
                            }))
                        )
                    : 
                        ''
                )
            );
    }
};

export default userBalanceTrasactionRow;
