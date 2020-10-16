import m from 'mithril';
import h from '../h';

const adminContribution = {
    view: function({attrs}) {
        const contribution = attrs.item;
        return m('.w-row.admin-contribution', [
            m('.fontweight-semibold.lineheight-tighter.u-marginbottom-10.fontsize-small', `R$${contribution.value}`),
            m('.fontsize-smallest.fontcolor-secondary', h.momentify(contribution.created_at, 'DD/MM/YYYY HH:mm[h]')),
            m('.fontsize-smallest', [
                'ID do Gateway: ',
                m(`a.alt-link[target="_blank"][href="https://dashboard.pagar.me/#/transactions/${contribution.gateway_id}"]`, contribution.gateway_id)
            ])
        ]);
    }
};

export default adminContribution;
