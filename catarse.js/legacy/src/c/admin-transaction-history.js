import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const adminTransactionHistory = {
    oninit: function(vnode) {
        const contribution = vnode.attrs.contribution,
            mapEvents = _.reduce([{
                date: contribution.paid_at,
                name: 'Apoio confirmado'
            }, {
                date: contribution.pending_refund_at,
                name: 'Reembolso solicitado'
            }, {
                date: contribution.refunded_at,
                name: 'Estorno realizado'
            }, {
                date: contribution.created_at,
                name: 'Apoio criado'
            }, {
                date: contribution.refused_at,
                name: 'Apoio cancelado'
            }, {
                date: contribution.deleted_at,
                name: 'Apoio excluído'
            }, {
                date: contribution.chargeback_at,
                name: 'Chargeback'
            }], (memo, item) => {
                if (item.date !== null && item.date !== undefined) {
                    item.originalDate = item.date;
                    item.date = h.momentify(item.date, 'DD/MM/YYYY, HH:mm');
                    return memo.concat(item);
                }

                return memo;
            }, []);

        vnode.state = {
            orderedEvents: _.sortBy(mapEvents, 'originalDate')
        };

        return vnode.state;
    },
    view: function({state}) {
        return m('.w-col.w-col-4', [
            m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20', 'Histórico da transação'),
            state.orderedEvents.map(cEvent => m('.w-row.fontsize-smallest.lineheight-looser.date-event', [
                m('.w-col.w-col-6', [
                    m('.fontcolor-secondary', cEvent.date)
                ]),
                m('.w-col.w-col-6', [
                    m('div', cEvent.name)
                ])
            ]))
        ]);
    }
};

export default adminTransactionHistory;
