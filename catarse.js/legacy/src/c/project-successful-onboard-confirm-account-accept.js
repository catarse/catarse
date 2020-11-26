/**
 * window.c.ProjectSuccessfulOnboardConfirmAccountAccept component
 * render confirmation message to accept bank data
 *
 * Example:
 * m.component(c.ProjectSuccessfulOnboardConfirmAccountAccept, {
 *    projectAccount: projectAccount,
 *    changeToAction: state.changeToAction //provided by ProjectSuccessfulOnboardConfirmAccount oninit
 * })
 * */
import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.successful_onboard.confirm_account');

const projectSuccessfulOnboardConfirmAccountAccept = {
    view: function({attrs}) {
        return m('.w-row.bank-transfer-answer', [
            m('.w-col.w-col-6.w-col-push-3', [
                m('.w-form.bank-transfer-confirm.card.u-radius', [
                    m('form#successful-onboard-form', [
                        m('a.w-inline-block.u-right.btn.btn-terciary.btn-no-border.btn-inline.fa.fa-close', { href: '#confirm_account', onclick: attrs.changeToAction('start') }),
                        m('label.field-label.fontweight-semibold.u-marginbottom-20', window.I18n.t('accept.title', I18nScope())),
                        m('.fontsize-smaller.u-marginbottom-30', window.I18n.t('accept.info', I18nScope())),
                        m('.w-row', [
                            m('.w-col.w-col-4.w-col-push-4', [
                                (!attrs.acceptAccountLoader() ?
                                 m('a.w-button.btn.btn-medium', {
                                     href: '#accept_account',
                                     onclick: attrs.acceptAccount
                                 }, window.I18n.t('accept.cta', I18nScope())) : h.loader())
                            ])
                        ])
                    ])
                ])
            ])
        ]);
    }
};

export default projectSuccessfulOnboardConfirmAccountAccept;
