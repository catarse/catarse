import m from 'mithril';
import _ from 'underscore';
import moment from 'moment';
import h from '../h';

const subscriptionsPerMonthTable = {
    oninit: function(vnode) {
        vnode.state = {
            emptyRow: {
                total_amount: 0,
                new_amount: 0,
                total_subscriptions: 0,
                new_subscriptions: 0
            }
        };
    },

    view: function({state, attrs}) {
        return m('div', [
            m(".fontsize-large.fontweight-semibold.u-text-center.u-marginbottom-30[id='origem']", 'Pagamentos confirmados por mês'),
            m('.table-outer.u-marginbottom-60', [
                m('.table-row.fontweight-semibold.fontsize-smaller.header.lineheight-tighter.w-row', [
                    m('.table-col.w-col.w-col-4.w-col-small-4.w-col-tiny-4',
                        m('div', 'Mês')
                    ),
                    m('.table-col.w-hidden-small.w-hidden-tiny.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                        m('div', [
                            'Pagamentos confirmados de Novas Assinaturas',
                            m.trust('&nbsp;')
                        ])
                    ),
                    m('.table-col.w-hidden-small.w-hidden-tiny.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                        m('div', 'Arrecadação com Novas Assinaturas')
                    ),
                    m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                        m('div', 'Pagamentos confirmados totais')
                    ),
                    m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                        m('div', 'Arrecadação total')
                    )
                ]),
                m('.table-inner.fontsize-small', [
                    !attrs.data ? '' :
                    _.map(_.groupBy(attrs.data, 'month'), (subscription) => {
                        const slip = _.filter(subscription, sub => sub.payment_method === 'boleto')[0] || state.emptyRow;
                        const credit_card = _.filter(subscription, sub => sub.payment_method === 'credit_card')[0] || state.emptyRow;

                        return m('.table-row.w-row', [
                            m('.table-col.w-col.w-col-4.w-col-small-4.w-col-stack.w-col-tiny-4', [
                                m('.fontweight-semibold', h.momentify(subscription[0].month, 'MMMM YYYY')),
                                m('.fontsize-smallest.fontcolor-secondary', 'Cartão de crédito'),
                                m('.fontsize-smallest.fontcolor-secondary', 'Boleto bancário')
                            ]),
                            m('.table-col.w-hidden-small.w-hidden-tiny.w-col.w-col-2.w-col-small-2.w-col-stack.w-col-tiny-2', [
                                m('.fontweight-semibold', slip.new_subscriptions + credit_card.new_subscriptions),
                                m('.fontsize-smallest.fontcolor-secondary', credit_card.new_subscriptions),
                                m('.fontsize-smallest.fontcolor-secondary', slip.new_subscriptions)
                            ]),
                            m('.table-col.w-hidden-small.w-hidden-tiny.w-col.w-col-2.w-col-small-2.w-col-stack.w-col-tiny-2', [
                                m('.fontweight-semibold', `R$${h.formatNumber((slip.new_amount + credit_card.new_amount) / 100, 2, 3)}`),
                                m('.fontsize-smallest.fontcolor-secondary', `R$${h.formatNumber((credit_card.new_amount) / 100, 2, 3)}`),
                                m('.fontsize-smallest.fontcolor-secondary', `R$${h.formatNumber((slip.new_amount) / 100, 2, 3)}`)
                            ]),
                            m('.w-col.w-col-2.w-col-small-2.w-col-stack.w-col-tiny-2', [
                                m('.fontweight-semibold', slip.total_subscriptions + credit_card.total_subscriptions),
                                m('.fontsize-smallest.fontcolor-secondary', credit_card.total_subscriptions),
                                m('.fontsize-smallest.fontcolor-secondary', slip.total_subscriptions)
                            ]),
                            m('.w-col.w-col-2.w-col-small-2.w-col-stack.w-col-tiny-2', [
                                m('.fontweight-semibold.text-success', `R$${h.formatNumber(((slip.total_amount) + (credit_card.total_amount)) / 100, 2, 3)}`),
                                m('.fontsize-smallest.fontcolor-secondary', `R$${h.formatNumber((credit_card.total_amount) / 100, 2, 3)}`),
                                m('.fontsize-smallest.fontcolor-secondary', `R$${h.formatNumber((slip.total_amount) / 100, 2, 3)}`)
                            ])
                        ]);
                    })
                ])
            ])
        ]);
    }
};

export default subscriptionsPerMonthTable;
