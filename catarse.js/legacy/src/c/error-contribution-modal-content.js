/**
 * window.c.errorContributionModalContent component
 * Render deliver error contribution modal
 *
 */
import m from 'mithril';

const errorContributionModalContent = {
    view: function({attrs}) {
        return m('div',

            m('.modal-dialog-header',
                m('.fontsize-large.u-text-center', [
                    m('span.fa.fa-exclamation-triangle',
                        ''
                    ),
                    ' Ops. Erro no envio!'
                ])
            ),
            m('.modal-dialog-content', [
                m('p.fontsize-small.u-marginbottom-30', [
                    m('span.fontweight-semibold',
                        `Você selecionou ${attrs.amount} apoios.`
                    ),
                    ' Após sua confirmação, os apoiadores que efetuaram esses apoios ao seu projeto serão notificados de que houve um problema com o envio de suas recompensas.'
                ]),
                m('.w-form', [
                    m('form', [
                        m('.fontsize-smaller',
                            'Se quiser adicionar alguma informação nessa mensagem, use o espaço abaixo (ex: você pode pedir confirmação de endereço de entrega ou explicar motivos do erro)'
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
                            'Você confirma que houve um erro no envio das recompensas dos apoios selecionados?'
                        )
                    ),
                    m('.w-col.w-col-1')
                ]),
                m('.w-row', [
                    m('.w-col.w-col-1'),
                    m('.w-col.w-col-5',
                        m('a.btn.btn-medium.w-button', {
                            onclick: () => attrs.updateStatus('error')
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

export default errorContributionModalContent;
