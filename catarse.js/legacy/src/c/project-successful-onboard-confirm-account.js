/**
 * window.c.ProjectSuccessfulOnboardConfirmAccount component
 * render project account data to confirm or redirect when error
 *
 * Example:
 * m.component(c.ProjectSuccessfulOnboardConfirmAccount, {projectAccount: projectAccount})
 * */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectSuccessfulOnboardConfirmAccountAccept from './project-successful-onboard-confirm-account-accept';

const I18nScope = _.partial(h.i18nScope, 'projects.successful_onboard.confirm_account');

const projectSuccessfulOnboardConfirmAccount = {
    oninit: function(vnode) {
        const actionStages = {
                accept: projectSuccessfulOnboardConfirmAccountAccept
            },
            currentStage = prop('start'),
            actionStage = () => actionStages[currentStage()],
            changeToAction = stage => () => {
                currentStage(stage);

                return false;
            };

        vnode.state = {
            changeToAction,
            actionStage,
            currentStage
        };
    },
    view: function({state, attrs}) {
        const projectAccount = attrs.projectAccount,
            actionStage = state.actionStage,
            currentStage = state.currentStage,
            juridicalPerson = projectAccount.user_type != 'pf';

        return m('.w-container.u-marginbottom-40', [
            m('.u-text-center', [
                m('.fontsize-large.fontweight-semibold.u-marginbottom-30', window.I18n.t('title', I18nScope()))
            ]),
            m('.w-row.u-marginbottom-40', [
                m('.w-col.w-col-6', [
                    m('.fontsize-base.u-marginbottom-30.card.card-terciary', [
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.label', I18nScope())),
                            window.I18n.t(`person.${projectAccount.user_type}.label`, I18nScope())
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t(`person.${projectAccount.user_type}.name`, I18nScope())),
                            projectAccount.owner_name
                        ]),
                        ((projectAccount.state_inscription && juridicalPerson) ? m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.state_inscription', I18nScope())),
                            projectAccount.state_inscription
                        ]) : ''),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t(`person.${projectAccount.user_type}.document`, I18nScope())),
                            projectAccount.owner_document
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.bank.name', I18nScope())),
                            projectAccount.bank_name
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.bank.agency', I18nScope())),
                            `${projectAccount.agency}${(_.isEmpty(projectAccount.agency_digit) ? '' : `-${projectAccount.agency_digit}`)}`
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.bank.account', I18nScope())),
                            `${projectAccount.account}-${projectAccount.account_digit} (${window.I18n.t(`person.bank.account_type.${projectAccount.account_type}`, I18nScope())})`
                        ])
                    ])
                ]),
                m('.w-col.w-col-6', [
                    m('.fontsize-base.u-marginbottom-30.card.card-terciary', [
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.address', I18nScope())),
                            `${projectAccount.address_street}, ${projectAccount.address_number} ${(!_.isNull(projectAccount.address_complement) ? `, ${projectAccount.address_complement}` : '')}`
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.neighbourhood', I18nScope())),
                            projectAccount.address_neighbourhood
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.city', I18nScope())),
                            projectAccount.address_city
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.state', I18nScope())),
                            projectAccount.address_state
                        ]),
                        m('div', [
                            m('span.fontcolor-secondary', window.I18n.t('person.zip_code', I18nScope())),
                            projectAccount.address_zip_code
                        ]),
                    ])
                ])
            ]),
            (currentStage() === 'start') ? m('#confirmation-dialog.w-row.bank-transfer-answer', [
                m('.w-col.w-col-3.w-col-small-6.w-col-tiny-6.w-hidden-small.w-hidden-tiny'),
                m('.w-col.w-col-3.w-col-small-6.w-col-tiny-6', [
                    m('a#confirm-account.btn.btn-large', { href: '#confirm_account', onclick: state.changeToAction('accept') }, 'Sim')
                ]),
                m('.w-col.w-col-3.w-col-small-6.w-col-tiny-6', [
                    m('a#refuse-account.btn.btn-large.btn-terciary', { href: `/projects/${projectAccount.project_id}/edit#user_settings` }, 'Não')
                ]),
                m('.w-col.w-col-3.w-col-small-6.w-col-tiny-6.w-hidden-small.w-hidden-tiny')
            ]) : m(actionStage(), {
                projectAccount,
                changeToAction: state.changeToAction,
                acceptAccount: attrs.acceptAccount,
                acceptAccountLoader: attrs.acceptAccountLoader
            })
        ]);
    }
};

export default projectSuccessfulOnboardConfirmAccount;
