/**
 * window.c.ProjectSuccessfulOnboardConfirmAccountError component
 * render error form to collect user answer
 *
 * Example:
 * m.component(c.ProjectSuccessfulOnboardConfirmAccountError, {
 *    projectAccount: projectAccount,
 *    changeToAction: state.changeToAction //provided by ProjectSuccessfulOnboardConfirmAccount oninit
 * })
 * */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.successful_onboard.confirm_account.refuse');

const projectSuccessfulOnboardConfirmAccountError = {
    oninit: function(vnode) {
        const errorReasonM = prop(''),
            error = prop(false);

        const addErrorReason = () => {
            if (errorReasonM().trim() === '')	{
                return error(true);
            }
            return vnode.attrs.addErrorReason(errorReasonM).call();
        };

        vnode.state = {
            addErrorReason,
            errorReasonM,
            error
        };
    },
    view: function({state, attrs}) {
        return m('.w-row.bank-transfer-answer', [
            m('.w-col.w-col-6.w-col-push-3', [
                m('.w-form.bank-transfer-problem.card.u-radius', [
                    m('form#successful-onboard-error', [
                        m('a.w-inline-block.u-right.btn.btn-terciary.btn-no-border.btn-inline.fa.fa-close', { href: '#confirm_account', onclick: attrs.changeToAction('start') }),
                        m('label.field-label.fontweight-semibold.u-marginbottom-20', window.I18n.t('title', I18nScope())),
                        m('textarea.w-input.text-field', {
                            placeholder: window.I18n.t('placeholder', I18nScope()),
                            class: state.error() ? 'error' : '',
                            onfocus: () => state.error(false),
                            onchange: m.withAttr('value', state.errorReasonM)
                        }),
                        state.error() ? m('.w-row', [
                            m('.w-col.w-col-6.w-col-push-3.u-text-center', [
                                m('span.fontsize-smallest.text-error', 'Campo Obrigatório')
                            ])
                        ]) : '',
                        m('.w-row', [
                            m('.w-col.w-col-4.w-col-push-4', [
                                m('a.w-button.btn.btn-medium', {
                                    href: '#confirm_account_refuse',
                                    onclick: state.addErrorReason
                                }, window.I18n.t('cta', I18nScope()))
                            ])
                        ])
                    ])
                ])
            ])
        ]);
    }
};

export default projectSuccessfulOnboardConfirmAccountError;
