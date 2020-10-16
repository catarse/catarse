import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import userVM from '../vms/user-vm';
import userAboutVM from '../vms/user-about-vm';
import railsErrorsVM from '../vms/rails-errors-vm';
import popNotification from './pop-notification';
import inlineError from './inline-error';
import projectEditSaveBtn from './project-edit-save-btn';

const userAboutEdit = {
    oninit: function(vnode) {
        let parsedErrors = userAboutVM.mapRailsErrors(railsErrorsVM.railsErrors());
        let deleteUser;
        const user = vnode.attrs.user || {},
            fields = {
                password: prop(''),
                current_password: prop(''),
                uploaded_image: prop(userVM.displayImage(user)),
                cover_image: prop(user.profile_cover_image || ''),
                email: prop(''),
                permalink: prop(user.permalink || ''),
                public_name: prop(user.public_name || ''),
                facebook_link: prop(user.facebook_link || ''),
                twitter: prop(user.twitter_username || ''),
                links: prop(user.links || []),
                about_html: prop(user.about_html || ''),
                email_confirmation: prop('')
            },
            passwordHasError = prop(false),
            emailHasError = prop(false),
            showEmailForm = h.toggleProp(false, true),
            showSuccess = prop(false),
            showError = prop(false),
            errors = prop(),
            loading = prop(false),
            uploading = prop(false),
            errorsArray = prop([]),
            pushErrosMessage = () => {
                errors(errorsArray().join('<br/>'));
            },
            updateFieldsFromUser = () => {
                userVM.fetchUser(vnode.attrs.userId, false).then((dataResponse) => {
                    const data = _.first(dataResponse);
                    fields.uploaded_image(userVM.displayImage(data));
                    fields.cover_image(data.profile_cover_image);
                    fields.permalink(data.permalink);
                    fields.public_name(data.public_name);
                    fields.facebook_link(data.facebook_link);
                    fields.twitter(data.twitter_username);
                    fields.links(data.links);
                    fields.about_html(data.about_html);
                });
            },
            uploadImage = () => {
                const userUploadedImageEl = window.document.getElementById('user_uploaded_image'),
                    userCoverImageEl = window.document.getElementById('user_cover_image'),
                    formData = new FormData();

                if (userUploadedImageEl.files[0] || (!vnode.attrs.hideCoverImg && userCoverImageEl.files[0])) {
                    formData.append('uploaded_image', userUploadedImageEl.files[0]);
                    if (!vnode.attrs.hideCoverImg) {
                        formData.append('cover_image', userCoverImageEl.files[0]);
                    }

                    uploading(true);
                    m.redraw();

                    return m.request({
                        method: 'POST',
                        url: `/users/${user.id}/upload_image.json`,
                        data: formData,
                        config: h.setCsrfToken,
                        serialize(data) {
                            return data;
                        }
                    }).then((data) => {
                        fields.uploaded_image(data.uploaded_image);
                        fields.cover_image(data.cover_image);
                        uploading(false);
                    }).catch((err) => {
                        if (_.isArray(err.errors)) {
                            errorsArray(errorsArray().concat(err.errors));
                        } else {
                            errors('Erro ao atualizar informações.');
                        }
                        pushErrosMessage();
                        showError(true);
                        uploading(false);
                    });
                }

                return void (0);
            },

            updateUser = () => {
                const userData = {
                    current_password: fields.current_password(),
                    password: fields.password(),
                    email: fields.email(),
                    permalink: fields.permalink(),
                    public_name: fields.public_name(),
                    facebook_link: fields.facebook_link(),
                    twitter: fields.twitter(),
                    about_html: fields.about_html(),
                    links_attributes: linkAttributes()
                };

                if (vnode.attrs.publishingUserAbout) {
                    userData.publishing_user_about = true;
                }

                loading(true);
                m.redraw();
                uploadImage();

                return m.request({
                    method: 'PUT',
                    url: `/users/${user.id}.json`,
                    data: {
                        user: userData
                    },
                    config: h.setCsrfToken
                }).then(() => {
                    showSuccess(true);
                    updateFieldsFromUser();
                    loading(false);
                    m.redraw();
                    railsErrorsVM.validatePublish();
                }).catch((err) => {
                    if (parsedErrors) {
                        parsedErrors.resetFieldErrors();
                    }
                    parsedErrors = userAboutVM.mapRailsErrors(err.errors_json);
                    emailHasError(parsedErrors.hasError('email'));
                    errors('Erro ao atualizar informações.');

                    showError(true);
                    loading(false);
                    m.redraw();
                });
            },
            removeLinks = [],
            addLink = () => fields.links().push({
                link: ''
            }),
            removeLink = (linkId, idx) => () => {
                fields.links()[idx]._destroy = true;
                return false;
            },
            linkAttributes = () => _.reduce(fields.links(), (memo, item, index) => {
                memo[index.toString()] = item;
                return memo;
            }, {}),
            validateEmailConfirmation = () => {
                if (fields.email() !== fields.email_confirmation()) {
                    emailHasError(true);
                    const emailConfirmationDiff = '{"email":["Confirmação de email está incorreta."]}';
                    parsedErrors = userAboutVM.mapRailsErrors(emailConfirmationDiff);
                } else {
                    emailHasError(false);
                }
                return !emailHasError();
            },
            validatePassword = () => {
                const pass = String(fields.password());
                if (pass.length > 0 && pass.length <= 5) {
                    passwordHasError(true);
                }

                return !passwordHasError();
            },
            setDeleteForm = (localVnode) => {
                deleteUser = () => localVnode.dom.submit();
            },
            deleteAccount = () => {
                if (window.confirm('Tem certeza que deseja desativar a sua conta?')) {
                    deleteUser();
                }

                return false;
            },
            onSubmit = (e) => {
                e.preventDefault();
                if (!validateEmailConfirmation()) {
                    errors('Confirmação de email está incorreta.');
                    showError(true);
                } else if (!validatePassword()) {
                    errors('Nova senha está incorreta.');
                    showError(true);
                } else {
                    updateUser();
                }
                return false;
            };
        // Temporary fix for the menu selection bug. Should be fixed/removed as soon as we route all tabs from mithril.
        setTimeout(m.redraw, 0);

        vnode.state = {
            removeLinks,
            removeLink,
            addLink,
            fields,
            loading,
            showSuccess,
            showError,
            errors,
            uploading,
            onSubmit,
            emailHasError,
            showEmailForm,
            validateEmailConfirmation,
            passwordHasError,
            validatePassword,
            deleteAccount,
            setDeleteForm,
            parsedErrors
        };
    },
    view: function({state, attrs}) {
        const user = attrs.user || {},
            fields = state.fields;

        return m('#about-tab.content', [
            (state.showSuccess() && !state.loading() && !state.uploading() ? m(popNotification, {
                message: 'As suas informações foram atualizadas'
            }) : ''),
            (state.showError() && !state.loading() && !state.uploading() ? m(popNotification, {
                message: m.trust(state.errors()),
                error: true
            }) : ''),
            m('form.simple_form.w-form', {
                onsubmit: state.onSubmit
            }, [
                m('input[name="utf8"][type="hidden"][value="✓"]'),
                m('input[name="_method"][type="hidden"][value="patch"]'),
                m(`input[name="authenticity_token"][type="hidden"][value=${h.authenticityToken()}]`),
                m('div',
                    m('.w-container',
                        m('.w-row',
                            m('.w-col.w-col-10.w-col-push-1', [!user.is_admin ? '' : m('.w-row.u-marginbottom-30.card.card-terciary', [
                                m('.w-col.w-col-5.w-sub-col', [
                                    m('label.field-label.fontweight-semibold',
                                            'Endereço do seu perfil'
                                        ),
                                    m('label.field-label.fontsize-smallest.fontcolor-secondary',
                                            'Seu perfil público pode ter uma URL personalizada. Escolha uma fácil de guardar!    '
                                        )
                                ]),
                                m('.w-col.w-col-7',
                                        m('.w-row', [
                                            m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6',
                                                m('input.string.optional.w-input.text-field.text-field.positive.prefix[id="user_permalink"][type="text"]', {
                                                    name: 'user[permalink]',
                                                    value: fields.permalink(),
                                                    onchange: m.withAttr('value', fields.permalink)
                                                })
                                            ),
                                            m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6.text-field.postfix.no-hover',
                                                m('.fontcolor-secondary.fontsize-smaller', '  .catarse.me')
                                            )
                                        ])
                                    )
                            ]),
                                m('.w-row.u-marginbottom-30.card.card-terciary', [
                                    m('.fontsize-base.fontweight-semibold',
                                        'Email'
                                    ),
                                    m('.fontsize-small.u-marginbottom-30',
                                        'Mantenha esse email atualizado pois ele é o canal de comunicação entre você, a equipe do Catarse e a equipe dos projetos que você apoiou. '
                                    ),
                                    m('.fontsize-base.u-marginbottom-40', [
                                        m('span.fontweight-semibold.card.u-radius',
                                            user.email
                                        ),
                                        m('a.alt-link.fontsize-small.u-marginleft-10[href=\'javascript:void(0);\'][id=\'update_email\']', {
                                            onclick: () => {
                                                state.showEmailForm.toggle();
                                            }
                                        },
                                            'Alterar email'
                                        )
                                    ]),
                                    m(`${state.showEmailForm() ? '' : '.w-hidden'}.u-marginbottom-20.w-row[id=\'email_update_form\']`, [
                                        m('.w-col.w-col-6.w-sub-col', [
                                            m('label.field-label.fontweight-semibold',
                                                'Novo email'
                                            ),
                                            m('input.w-input.text-field.positive[id=\'new_email\'][name=\'new_email\'][type=\'email\']', {
                                                class: state.emailHasError() ? 'error' : '',
                                                value: fields.email(),
                                                onfocus: () => state.emailHasError(false),
                                                onchange: m.withAttr('value', fields.email)
                                            })
                                        ]),
                                        m('.w-col.w-col-6', [
                                            m('label.field-label.fontweight-semibold',
                                                'Confirmar novo email'
                                            ),
                                            m('input.string.required.w-input.text-field.w-input.text-field.positive[id=\'new_email_confirmation\'][name=\'user[email]\'][type=\'text\']', {
                                                class: state.emailHasError() ? 'error' : '',
                                                value: fields.email_confirmation(),
                                                onfocus: () => state.emailHasError(false),
                                                onblur: state.validateEmailConfirmation,
                                                onchange: m.withAttr('value', fields.email_confirmation)
                                            })
                                        ]),
                                        state.emailHasError() ? state.parsedErrors.inlineError('email') : ''
                                    ])
                                ]),
                                m('.w-row.u-marginbottom-30.card.card-terciary', [
                                    m('.w-col.w-col-5.w-sub-col', [
                                        m('label.field-label.fontweight-semibold',
                                            '  Nome no perfil público'
                                        ),
                                        m('label.field-label.fontsize-smallest.fontcolor-secondary',
                                            'Esse é o nome que os usuários irão ver no seu perfil.'
                                        )
                                    ]),
                                    m('.w-col.w-col-7',
                                        m('input.string.optional.w-input.text-field.positive[id="user_public_name"][type="text"]', {
                                            name: 'user[public_name]',
                                            class: state.parsedErrors.hasError('public_name') ? 'error' : false,
                                            value: fields.public_name(),
                                            onchange: m.withAttr('value', fields.public_name)
                                        }),
                                        state.parsedErrors.inlineError('public_name')
                                    )
                                ]),
                                m('.w-form', [
                                    m('.w-row.u-marginbottom-30.card.card-terciary', [
                                        m('.w-col.w-col-5.w-sub-col', [
                                            m('label.field-label.fontweight-semibold',
                                                '  Imagem do perfil'
                                            ),
                                            m('label.field-label.fontsize-smallest.fontcolor-secondary',
                                                '  Essa imagem será utilizada como a miniatura de seu perfil (PNG, JPG tamanho 280 x 280)'
                                            )
                                        ]),
                                        m('.w-col.w-col-4.w-sub-col',
                                            m('.input.file.optional.user_uploaded_image.field_with_hint', [
                                                m('label.field-label'),
                                                m('span.hint',
                                                    m(`img[alt="Avatar do Usuario"][src="${fields.uploaded_image()}"]`)
                                                ),
                                                m('input.file.optional.w-input.text-field[id="user_uploaded_image"][type="file"]', {
                                                    name: 'user[uploaded_image]',
                                                    class: state.parsedErrors.hasError('uploaded_image') ? 'error' : false
                                                }),
                                                state.parsedErrors.inlineError('uploaded_image')
                                            ])
                                        )
                                    ]),
                                    (attrs.hideCoverImg ? '' : m('.w-row.u-marginbottom-30.card.card-terciary', [
                                        m('.w-col.w-col-5.w-sub-col', [
                                            m('label.field-label.fontweight-semibold',
                                                '  Imagem de capa do perfil'
                                            ),
                                            m('label.field-label.fontsize-smallest.fontcolor-secondary',
                                                '  Essa imagem será utilizada como fundo do cabeçalho do seu perfil público (PNG ou JPG). Caso você não envie nenhum imagem aqui, utilizaremos sua imagem de perfil como alternativa.'
                                            )
                                        ]),
                                        m('.w-col.w-col-4.w-sub-col',
                                            m('.input.file.optional.user_cover_image', [
                                                m('label.field-label'),
                                                m('span.hint',
                                                    user.profile_cover_image ? m('img', {
                                                        src: fields.cover_image()
                                                    }) : ''
                                                ),
                                                m('input.file.optional.w-input.text-field[id="user_cover_image"][type="file"]', {
                                                    name: 'user[cover_image]'
                                                })
                                            ])
                                        )
                                    ]))
                                ]),
                                m('.w-row',
                                    m('.w-col',
                                        m('.card.card-terciary.u-marginbottom-30', [
                                            m('label.field-label.fontweight-semibold',
                                                'Sobre'
                                            ),
                                            m('label.field-label.fontsize-smallest.fontcolor-secondary.u-marginbottom-20',
                                                'Fale sobre você e tente fornecer as informações mais relevantes para que visitantes possam te conhecer melhor. '
                                            ),
                                            m('.w-form',
                                                m('.preview-container.u-marginbottom-40', {
                                                    class: state.parsedErrors.hasError('about_html') ? 'error' : false
                                                }, h.redactor('user[about_html]', fields.about_html)),
                                                state.parsedErrors.inlineError('about_html')
                                            )
                                        ])
                                    )
                                ),
                                m('.w-form.card.card-terciary.u-marginbottom-30', [
                                    m('.w-row.u-marginbottom-10', [
                                        m('.w-col.w-col-5.w-sub-col', [
                                            m('label.field-label.fontweight-semibold',
                                                '  Perfil do facebook'
                                            ),
                                            m('label.field-label.fontsize-smallest.fontcolor-secondary',
                                                '  Cole o link do seu perfil'
                                            )
                                        ]),
                                        m('.w-col.w-col-7',
                                            m('input.string.optional.w-input.text-field.positive[type="text"]', {
                                                name: 'user[facebook_link]',
                                                value: fields.facebook_link(),
                                                onchange: m.withAttr('value', fields.facebook_link)
                                            })
                                        )
                                    ]),
                                    m('.w-row.u-marginbottom-10', [
                                        m('.w-col.w-col-5.w-sub-col', [
                                            m('label.field-label.fontweight-semibold',
                                                '  Perfil do twitter'
                                            ),
                                            m('label.field-label.fontsize-smallest.fontcolor-secondary',
                                                '  Cole o link do seu perfil'
                                            )
                                        ]),
                                        m('.w-col.w-col-7',
                                            m('input.string.optional.w-input.text-field.positive[type="text"]', {
                                                name: 'user[twitter]',
                                                value: fields.twitter(),
                                                onchange: m.withAttr('value', fields.twitter)
                                            })
                                        )
                                    ])
                                ]),
                                m('.w-form.card.card-terciary.u-marginbottom-30',
                                    m('.w-row.u-marginbottom-10', [
                                        m('.w-col.w-col-5.w-sub-col', [
                                            m('label.field-label.fontweight-semibold[for="name-8"]',
                                                ' Presença na internet'
                                            ),
                                            m('label.field-label.fontsize-smallest.fontcolor-secondary[for="name-8"]', ' Inclua links que ajudem outros usuários a te conhecer melhor. ')
                                        ]),
                                        m('.w-col.w-col-7', [
                                            m('.w-row', [fields.links() && fields.links().length <= 0 ? '' : m('.link', _.map(fields.links(),
                                                (link, idx) => {
                                                    const toRemove = link._destroy;

                                                    return m('div', {
                                                        key: idx,
                                                        class: toRemove ? 'w-hidden' : 'none'
                                                    }, [
                                                        m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10',
                                                            m(`input.string.w-input.text-field.w-input.text-field][type="text"][value="${link.link}"]`, {
                                                                class: link.link === '' ? 'positive' : 'optional',
                                                                name: `user[links_attributes][${idx}][link]`,
                                                                onchange: m.withAttr('value', val => fields.links()[idx].link = val)
                                                            })
                                                        ),
                                                        m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2', [
                                                            m('a.btn.btn-small.btn-terciary.fa.fa-lg.fa-trash.btn-no-border', {
                                                                onclick: state.removeLink(link.id, idx)
                                                            })
                                                        ])
                                                    ]);
                                                }
                                            ))]),
                                            m('.w-row', [
                                                m('.w-col.w-col-6.w-col-push-6',
                                                    m('a.btn.btn-small.btn-terciary', {
                                                        onclick: state.addLink
                                                    },
                                                        m('span.translation_missing', 'Add Link')
                                                    )
                                                )
                                            ])
                                        ])
                                    ])
                                ),
                                (attrs.hidePasswordChange ? '' : m('.w-form.card.card-terciary.u-marginbottom-30',
                                    m('.w-row.u-marginbottom-10', [
                                        m('.fontsize-base.fontweight-semibold',
                                            'Alterar minha senha'
                                        ),
                                        m('.fontsize-small.u-marginbottom-20',
                                            'Para que a senha seja alterada você precisa confirmar a sua senha atual.'
                                        ),
                                        m('.w-row.u-marginbottom-20', [
                                            m('.w-col.w-col-6.w-sub-col', [
                                                m('label.field-label.fontweight-semibold',
                                                    ' Senha atual'
                                                ),
                                                m('input.password.optional.w-input.text-field.w-input.text-field.positive[id=\'user_current_password\'][name=\'user[current_password]\'][type=\'password\']', {
                                                    value: fields.current_password(),
                                                    onchange: m.withAttr('value', fields.current_password)
                                                })
                                            ]),
                                            m('.w-col.w-col-6', [
                                                m('label.field-label.fontweight-semibold',
                                                    ' Nova senha'
                                                ),
                                                m('input.password.optional.w-input.text-field.w-input.text-field.positive[id=\'user_password\'][name=\'user[password]\'][type=\'password\']', {
                                                    class: state.passwordHasError() ? 'error' : '',
                                                    value: fields.password(),
                                                    onfocus: () => state.passwordHasError(false),
                                                    onblur: state.validatePassword,
                                                    onchange: m.withAttr('value', fields.password)
                                                }), !state.passwordHasError() ? '' : m(inlineError, {
                                                    message: 'A sua nova senha deve ter no mínimo 6 caracteres.'
                                                })
                                            ])
                                        ]),

                                    ])
                                )),
                                (!user.is_admin && (attrs.hideDisableAcc || user.total_published_projects > 0) ? '' : m('.w-form.card.card-terciary.u-marginbottom-30',
                                    m('.w-row.u-marginbottom-10', [
                                        m('.fontweight-semibold.fontsize-smaller',
                                            'Desativar minha conta'
                                        ),
                                        m('.fontsize-smallest',
                                            'Todos os seus apoios serão convertidos em apoios anônimos, seus dados não serão mais visíveis, você sairá automaticamente do sistema e sua conta será desativada permanentemente.'
                                        ),
                                        m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}'][rel='nofollow']`, {
                                            onclick: state.deleteAccount
                                        },
                                            'Desativar minha conta no Catarse'
                                        ),
                                        m('form.w-hidden', {
                                            action: `/${window.I18n.locale}/users/${user.id}`,
                                            method: 'post',
                                            oncreate: state.setDeleteForm
                                        }, [
                                            m(`input[name='authenticity_token'][type='hidden'][value='${h.authenticityToken()}']`),
                                            m('input[name=\'_method\'][type=\'hidden\'][value=\'delete\']')
                                        ])

                                    ])
                                ))

                            ])
                        )
                    ),
                    m(projectEditSaveBtn, {
                        loading: state.loading,
                        onSubmit: state.onSubmit
                    })
                )

            ])
        ]);
    }
};

export default userAboutEdit;
