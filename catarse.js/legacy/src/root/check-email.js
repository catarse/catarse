import m from 'mithril';
import prop from 'mithril/stream';
import moment from 'moment';
import _ from 'underscore';
import h from '../h';
import userVM from '../vms/user-vm';

const I18nScope = _.partial(h.i18nScope, 'users.edit.email_confirmation');

const CheckEmail = {
    oninit: function(vnode) {
        const userID = h.getUserID(),
            user = userVM.getCurrentUser(),
            confirmedEmail = prop(false),
            hideAlert = prop(false);

        vnode.state = {
            confirmedEmail,
            hideAlert,
            user,
            checkEmail: () => m.request({
                method: 'PUT',
                url: `/users/${userID}.json`,
                data: {
                    user: {
                        confirmed_email_at: true
                    }
                },
                config: h.setCsrfToken
            }).then((data) => {
                confirmedEmail(true);
                window.setTimeout(() => {
                    hideAlert(true);
                    m.redraw(true);
                }, 4000);
            })
        };
    },

    view: function({state, attrs}) {
        
        const user = state.user();

        if (user) {
            const userCreatedRecently = moment().isBefore(moment(user.created_at).add(2, 'days'));

            return ((user && !userCreatedRecently && !user.email_active && !state.hideAlert()) ? m('.card-alert.section.u-text-center', { style: (attrs.menuTransparency ? { 'padding-top': '100px' } : {}) }, [
                m('.w-container', (state.confirmedEmail() ? [
                    m('.fontsize-large.fontweight-semibold', window.I18n.t('confirmed_title', I18nScope())),
                    m('.fontsize-large.fontweight-semibold.u-marginbottom-20', window.I18n.t('confirmed_sub', I18nScope())),
                ] : [
                    m('.fontsize-large.fontweight-semibold', _.isNull(user.name) ? 'Olá' : window.I18n.t('hello', I18nScope({ name: user.name }))),
                    m('.fontsize-large.fontweight-semibold.u-marginbottom-20', window.I18n.t('hello_sub', I18nScope())),
                    m('.fontsize-base.u-marginbottom-10', window.I18n.t('hello_email', I18nScope({ email: user.email }))),
                    m('.w-row', [
                        m('.w-col.w-col-3'),
                        m('.w-col.w-col-3', [
                            m('button.btn.btn-medium.btn-terciary.w-button', {
                                onclick: state.checkEmail
                            }, 'Sim!')
                        ]),
                        m('.w-col.w-col-3', [
                            m(`a.btn.btn-medium.w-button[href="/users/${user.id}/edit#about_me"]`, 'Editar o email')
                        ]),
                        m('.w-col.w-col-3')
                    ])
                ]))
            ]) : m('div'));
        }

        return m('div');
    }
};

export default CheckEmail;
