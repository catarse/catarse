import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.reward_fields');

const rewardCardBig = {
    view: function({attrs}) {
        const reward = attrs.reward;

        return m('.card.u-radius', [
            m('.fontsize-large.fontweight-semibold.u-marginbottom-10',
                `R$${reward.minimum_value} ou mais${reward.title ? `: ${reward.title}` : ''}`
            ),
            m('.fontcolor-secondary.fontsize-small.u-marginbottom-20',
                `${reward.description.substring(0, 140)}...`
            ),
            m('.fontcolor-secondary.fontsize-smallest', [
                m('span.fontcolor-terciary',
                    'Entrega prevista: '
                ),
                h.momentify(reward.deliver_at, 'MMMM/YYYY'),
                m('span.fontcolor-terciary', '    |    '),
                m('span.fontcolor-terciary', 'Envio: '),
                window.I18n.t(`shipping_options.${reward.shipping_options}`, I18nScope())
            ])
        ]);
    }
};

export default rewardCardBig;
