import m from 'mithril';
import h from '../h';

const adminSubscription = {
    view: function({attrs}) {
        const subscription = attrs.item;
        return m('.w-row.admin-contribution', [
            m('.fontweight-semibold.fontsize-small',
              `R$${subscription.amount / 100} por mês`
             ),
            m('.fontsize-smaller.fontweight-semibold',
              `(${subscription.paid_count} mês ativo)`
             )
        ]);
    }
};

export default adminSubscription;
