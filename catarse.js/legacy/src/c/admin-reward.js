import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore'
import h from '../h';
import { catarse } from '../api';
import models from '../models';

const adminReward = {
    oninit: function(vnode) {
        let l;
        const loadShippingFee = () => {
            const shippingFee = prop({});

            if (vnode.attrs.contribution.shipping_fee_id) {
                const options = models.shippingFee.getRowOptions(
                    h.idVM.id(
                        vnode.attrs.contribution.shipping_fee_id
                    ).parameters());

                l = catarse.loaderWithToken(options);
                l.load().then(_.compose(shippingFee, _.first));
            }

            return shippingFee;
        };

        vnode.state = {
            shippingFee: loadShippingFee()
        };

        return vnode.state;
    },

    view: function({state, attrs}) {
        const reward = attrs.reward(),
            contribution = attrs.contribution,
            available = parseInt(reward.paid_count) + parseInt(reward.waiting_payment_count),
            shippingFee = state.shippingFee();

        return m('.w-col.w-col-4', [
            m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20', 'Recompensa'),
            m('.fontsize-smallest.lineheight-looser', reward.id ? [
                `ID: ${reward.id}`,
                m('br'),
                `Local de entrega: ${(shippingFee.destination ? `${shippingFee.destination} R$ ${shippingFee.value}` : 'Nenhum')}`,
                m('br'),
                `Envio: ${window.I18n.t(`shared.shipping_options.${reward.shipping_options}`)}`,
                m('br'),
                `Valor mínimo: R$${h.formatNumber(reward.minimum_value, 2, 3)}`,
                m('br'),
                m.trust(`Disponíveis: ${available} / ${reward.maximum_contributions || '&infin;'}`),
                m('br'),
                `Aguardando confirmação: ${reward.waiting_payment_count}`,
                m('br'),
                `Estimativa da Entrega: ${h.momentify(reward.deliver_at)}`,
                m('br'),
                m('div', [
                    'Status da Entrega: ',
                    h.contributionStatusBadge(contribution),
                ]),
                (reward.title ? [`Título: ${reward.title}`,
                    m('br')
                ] : ''),
                `Descrição: ${reward.description}`
            ] : 'Apoio sem recompensa')
        ]);
    }
};

export default adminReward;
