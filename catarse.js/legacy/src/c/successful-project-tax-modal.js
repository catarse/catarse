/**
 * window.c.SuccessfulProjectTaxModal component
 * Modal content for show project transfer complete values data
 */
import m from 'mithril';
import h from '../h';

const successfulProjectTaxModal = {
    view: function({attrs}) {
        const pt = attrs.projectTransfer;

        return m('div', [
            m('.modal-dialog-header', [
                m('.fontsize-large.u-text-center',
                  'Extrato do projeto')
            ]),
            m('.modal-dialog-content', [
                m('p.fontsize-small.u-marginbottom-40', [
                    'Confira o extrato do seu projeto, já incluindo as taxas e retenções. Se você tiver dúvidas sobre como esse cálculo é feito, ',
                    m('a.alt-link[href="http://suporte.catarse.me/hc/pt-br/articles/202037493-FINANCIADO-Como-ser%C3%A1-feito-o-repasse-do-dinheiro-"][target="__blank"]', 'acesse aqui'),
                    '.'
                ]),
                m('div', [
                    m('.w-row.fontsize-small.u-marginbottom-10', [
                        m('.w-col.w-col-4', [
                            m('.text-success', `+ R$ ${h.formatNumber(pt.pledged, 2)}`)
                        ]),
                        m('.w-col.w-col-8', [
                            m('div', `Arrecadação total (${pt.total_contributions} apoios)`)
                        ])
                    ]),
                    (pt.irrf_tax > 0 ?
                     m('.w-row.fontsize-small.u-marginbottom-10', [
                         m('.w-col.w-col-4', [
                             m('.text-success', `+ R$ ${h.formatNumber(pt.irrf_tax, 2)}`)
                         ]),
                         m('.w-col.w-col-8', [
                             m('div', 'Retenção IRF (Imposto de Renda na Fonte)')
                         ])
                     ]) : ''),
                    m('.w-row.fontsize-small.u-marginbottom-10', [
                        m('.w-col.w-col-4', [
                            m('.text-error', `- R$ ${h.formatNumber(pt.catarse_fee, 2)}`)
                        ]),
                        m('.w-col.w-col-8', [
                            m('div', `Taxa do Catarse e meio de pagamento (${h.formatNumber((pt.service_fee * 100), 2)}%) `)
                        ])
                    ]),
                    m('.divider.u-marginbottom-10'),
                    m('.w-row.fontsize-base.fontweight-semibold', [
                        m('.w-col.w-col-4', [
                            m('div', `R$ ${h.formatNumber(pt.total_amount, 2)}`)
                        ]),
                        m('.w-col.w-col-8', [
                            m('div', 'Total a ser transferido')
                        ])
                    ])
                ])
            ])
        ]);
    }
};

export default successfulProjectTaxModal;
