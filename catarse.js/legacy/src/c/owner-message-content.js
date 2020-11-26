/**
 * window.c.OwnerMessageContent component
 * Render project owner contact form
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import userVM from '../vms/user-vm';

const ownerMessageContent = {
    oninit: function(vnode) {
        let l = prop(false);
        const sendSuccess = prop(false),
            userDetails = vnode.attrs,
            submitDisabled = prop(false),
            // sets default values when user is not logged in
            user = h.getUser() || {
                name: '',
                email: '',
            },
            from_name = prop(userVM.displayName(user)),
            from_email = prop(user.email),
            content = prop('');

        const sendMessage = () => {
            if (l()) {
                return false;
            }
            submitDisabled(true);
            content(
                content()
                    .split('\n')
                    .join('<br />')
            );

            const loaderOpts = models.directMessage.postOptions({
                from_name: from_name(),
                from_email: from_email(),
                user_id: h.getUser().user_id,
                content: content(),
                project_id: vnode.attrs.project_id,
                to_user_id: userDetails.id,
                data: {
                    page_title: document.title,
                    page_url: window.location.href,
                },
            });

            l = catarse.loaderWithToken(loaderOpts);

            l.load().then(sendSuccess(true));

            submitDisabled(false);
            return false;
        };

        vnode.state = {
            sendMessage,
            submitDisabled,
            sendSuccess,
            userDetails: vnode.attrs,
            from_name,
            from_email,
            content,
            l,
        };
    },
    view: function({ state, attrs }) {
        const successMessage = m('.modal-dialog-content.u-text-center', [
                m('.fa.fa-check-circle.fa-5x.text-success.u-marginbottom-40'),
                m(
                    'p.fontsize-large',
                    `Sua mensagem foi enviada com sucesso para ${
                        state.userDetails.name
                    }. Você vai receber uma cópia no seu email e pode seguir a conversa por lá!`
                ),
            ]),
            contactForm = [
                m('.modal-dialog-content', [
                    m('.w-form', [
                        m(
                            'form',
                            {
                                onsubmit: h.validate().submit(
                                    [
                                        {
                                            prop: state.from_name,
                                            rule: 'text',
                                        },
                                        {
                                            prop: state.from_email,
                                            rule: 'email',
                                        },
                                        {
                                            prop: state.content,
                                            rule: 'text',
                                        },
                                    ],
                                    state.sendMessage
                                ),
                            },
                            [
                                m('.w-row', [
                                    m('.w-col.w-col-6.w-sub-col', [
                                        m('label.fontsize-smaller', 'Seu nome'),
                                        m(`input.w-input.text-field[value='${state.from_name()}'][type='text'][required='required']`, {
                                            onchange: m.withAttr('value', state.from_name),
                                            class: h.validate().hasError(state.from_name) ? 'error' : '',
                                        }),
                                    ]),
                                    m('.w-col.w-col-6', [
                                        m('label.fontsize-smaller', 'Seu email'),
                                        m(`input.w-input.text-field[value='${state.from_email()}'][type='text'][required='required']`, {
                                            onchange: m.withAttr('value', state.from_email),
                                            class: h.validate().hasError(state.from_email) ? 'error' : '',
                                        }),
                                    ]),
                                ]),
                                m('label', 'Mensagem'),
                                m("textarea.w-input.text-field.height-small[required='required']", {
                                    onchange: m.withAttr('value', state.content),
                                    class: h.validate().hasError(state.content) ? 'error' : '',
                                }),
                                m('.u-marginbottom-10.fontsize-smallest.fontcolor-terciary', 'Você receberá uma cópia desta mensagem em seu email.'),
                                m(
                                    '.w-row',
                                    h.validationErrors().length
                                        ? _.map(h.validationErrors(), errors =>
                                              m('span.fontsize-smallest.text-error', [m('span.fa.fa-exclamation-triangle'), ` ${errors.message}`, m('br')])
                                          )
                                        : ''
                                ),
                                m(
                                    '.modal-dialog-nav-bottom',
                                    m(
                                        '.w-row',
                                        m(
                                            '.w-col.w-col-6.w-col-push-3',
                                            !state.l()
                                                ? m('input.w-button.btn.btn-large[type="submit"][value="Enviar mensagem"]', {
                                                      disabled: state.submitDisabled(),
                                                  })
                                                : h.loader()
                                        )
                                    )
                                ),
                            ]
                        ),
                    ]),
                ]),
            ];

        return m('div', [m('.modal-dialog-header', m('.fontsize-large.u-text-center', 'Enviar mensagem')), state.sendSuccess() ? successMessage : contactForm]);
    },
};

export default ownerMessageContent;
