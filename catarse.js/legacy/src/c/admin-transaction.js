import m from 'mithril';
import h from '../h';

const adminTransaction = {
    view: function({attrs}) {
        const contribution = attrs.contribution;
        return m('.w-col.w-col-4', [
            m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-20', 'Detalhes do apoio'),
            m('.fontsize-smallest.lineheight-looser', [
                `Valor: R$${h.formatNumber(contribution.value, 2, 3)}`,
                m('br'),
                `Taxa: R$${h.formatNumber(contribution.gateway_fee, 2, 3)}`,
                m('br'),
                `Aguardando Confirmação: ${contribution.waiting_payment ? 'Sim' : 'Não'}`,
                m('br'),
                `Anônimo: ${contribution.anonymous ? 'Sim' : 'Não'}`,
                m('br'),
                `Id pagamento: ${contribution.gateway_id}`,
                m('br'),
                `Apoio: ${contribution.contribution_id}`,
                m('br'),
                'Chave: \n',
                m('br'),
                contribution.key,
                m('br'),
                `Meio: ${contribution.gateway}`,
                m('br'),
                `Operadora: ${contribution.gateway_data && contribution.gateway_data.acquirer_name}`,
                contribution.is_second_slip ? [m('br'), m('a.link-hidden[href="#"]', 'Boleto bancário'), ' ', m('span.badge', '2a via')] : ''
            ])
        ]);
    }
};

export default adminTransaction;
