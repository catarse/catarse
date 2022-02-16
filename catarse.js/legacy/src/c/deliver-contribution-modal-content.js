/**
 * window.c.deliverContributionModalContent component
 * Render deliver contribution modal
 *
 */
import m from 'mithril';

const deliverContributionModalContent = {
    view: function({attrs}) {
        return m('div',
            m('.modal-dialog-header',
                m('.fontsize-large.u-text-center', [
                    m('span.fa.fa-check-circle',
                        ''
                    ),
                    ' Recompensas a caminho!'
                ])
            ),
            m('.modal-dialog-content', [
                m('p.fontsize-small.u-marginbottom-30', [
                    m('span.fontweight-semibold',
                        `Você selecionou ${attrs.amount} apoios.`
                    ),
                    ' Após sua confirmação, os apoiadores que efetuaram esses apoios ao seu projeto serão notificados de que suas recompensas foram enviadas.'
                ]),
                m('.w-form', [
                    m('form', [
                        m('.fontsize-smaller',
                            'Se quiser adicionar alguma informação nessa mensagem, use o espaço abaixo. É um ótimo momento para agradecer a essas pessoas que acreditaram em você!'
                        ),
                        m("textarea.height-mini.text-field.w-input[placeholder='Digite sua mensagem (opcional)']", {
                            value: attrs.message(),
                            onchange: m.withAttr('value', attrs.message)
                        })
                    ]),
                ]),
                m('.w-row', [
                    m('.w-col.w-col-1'),
                    m('.w-col.w-col-10',
                        m('.fontsize-small.fontweight-semibold.u-marginbottom-20.u-text-center',
                            'Você confirma que a recompensa dos apoios selecionados foram enviadas?'
                        )
                    ),
                    m('.w-col.w-col-1')
                ]),
                m('.w-row', [
                    m('.w-col.w-col-1'),
                    m('.w-col.w-col-5',
                        m('a.btn.btn-medium.w-button', {
                            onclick: () => attrs.updateStatus('delivered')
                        },
                            'Sim!'
                        )
                    ),
                    m('.w-col.w-col-5',
                        m('a.btn.btn-medium.btn-terciary.w-button', {
                            onclick: attrs.displayModal.toggle
                        },
                            'Voltar'
                        )
                    ),
                    m('.w-col.w-col-1')
                ])
            ]));
    }
};

export default deliverContributionModalContent;
