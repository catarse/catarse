/**
 * window.c.cancelProjectModalContent component
 * Render cancel project modal
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';

const cancelProjectModalContent = {
    oninit: function(vnode) {
        const checkError = prop(false),
            showRedactor = prop(false),
            check = prop(''),
            commentHtml = prop(''),
            showNextModal = () => {
                if (check() === 'cancelar-projeto') {
                    showRedactor(true);
                } else {
                    checkError(true);
                }
                return false;
            };

        vnode.state = {
            showNextModal,
            commentHtml,
            showRedactor,
            checkError,
            check
        };
    },

    view: function({state, attrs}) {
        return m(`form.cancel-project-modal.modal-dialog-content[accept-charset='UTF-8'][action='/${window.I18n.locale}/projects/${attrs.project.id}'][id='edit_project_${attrs.project.id}'][method='post'][novalidate='novalidate']`,
            state.showRedactor() ? [
                m("input[name='utf8'][type='hidden'][value='✓']"),
                m("input[name='_method'][type='hidden'][value='patch']"),
                m(`input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`),
                m("input[id='anchor'][name='anchor'][type='hidden'][value='posts']"),
                m("input[id='cancel_project'][name='cancel_project'][type='hidden'][value='true']"),
                m('.fontsize-smaller.u-marginbottom-20',
                    'Conte porque você está cancelando sua campanha. Essa mensagem será enviada por email para os seus apoiadores e estará pública na aba "Novidades" do seu projeto no Catarse.'
                ),
                m('.w-form', [
                    m("label.string.required.field-label.field-label.fontweight-semibold[for='project_posts_attributes_0_title']",
                        'Título'
                    ),
                    m("input.string.required.w-input.text-field.w-input.text-field.positive[id='project_posts_attributes_0_title'][name='project[posts_attributes][0][title]'][type='text']"),
                    m("label.string.optional.field-label.field-label.fontweight-semibold[for='project_posts_attributes_0_comment']",
                        'Texto'
                    ),
                    h.redactor('project[posts_attributes][0][comment_html]', state.commentHtml)
                ]),
                m('div',
                    m('.w-row', [
                        m('.w-col.w-col-3'),
                        m('.u-text-center.w-col.w-col-6', [
                            m("input.btn.btn-inactive.btn-large.u-marginbottom-20[name='commit'][type='submit'][value='Cancelar campanha']"),
                            m(".fontsize-small.link-hidden-light[id='modal-close']", {
                                onclick: attrs.displayModal.toggle
                            },
                                'Cancelar'
                            )
                        ]),
                        m('.w-col.w-col-3')
                    ])
                )
            ] : [
                m('.fontsize-small.u-marginbottom-20', [
                    'Após o cancelamento, sua campanha será expirada e os seus apoiadores serão reembolsados dentro das próximas 24h horas.',
                    m('span.fontweight-semibold',
                        'Essa ação não poderá ser desfeita!'
                    ),
                    m('br'),
                    m('span.fontweight-semibold')
                ]),
                m('.fontsize-small.u-marginbottom-10', [
                    'Se você tem certeza que deseja cancelar seu projeto, confirme escrevendo ',
                    m('span.fontweight-semibold.text-error',
                        'cancelar-projeto '
                    ),
                    'no campo abaixo. Em seguida lhe pediremos para escrever uma mensagem aos apoiadores e seu projeto será então cancelado.',
                    m('span.fontweight-semibold.text-error')
                ]),
                m('.w-form', [
                    m('input.positive.text-field.u-marginbottom-40.w-input[maxlength=\'256\'][type=\'text\']', {
                        class: !state.checkError() ? false : 'error',
                        placeholder: 'cancelar-projeto',
                        onchange: m.withAttr('value', state.check)
                    })
                ]),
                m('div',
                    m('.w-row', [
                        m('.w-col.w-col-3'),
                        m('.u-text-center.w-col.w-col-6', [
                            m('button.btn.btn-inactive.btn-large.u-marginbottom-20', {
                                onclick: state.showNextModal
                            }, 'Próximo passo >'),
                            m('a.fontsize-small.link-hidden-light[href=\'#\']', {
                                onclick: attrs.displayModal.toggle
                            },
                                'Cancelar'
                            )
                        ]),
                        m('.w-col.w-col-3')
                    ])
                )
            ]);
    }
};

export default cancelProjectModalContent;
