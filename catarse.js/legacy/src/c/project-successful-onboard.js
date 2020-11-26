/**
 * window.c.ProjectSuccessfulOnboard component
 * render first interaction of successful project onboarding
 * used when project is successful and wants to confirm bank data and request transfer
 *
 * Example:
 * m.component(c.ProjectSuccessfulOnboard, {project: project})
 * */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';
import projectSuccessfulOnboardConfirmAccount from './project-successful-onboard-confirm-account';
import modalBox from './modal-box';
import successfulProjectTaxModal from './successful-project-tax-modal';
import insightVM from '../vms/insight-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.successful_onboard');

const projectSuccessfulOnboard = {
    oninit: function(vnode) {
        const projectIdVM = catarse.filtersVM({ project_id: 'eq' }),
            projectAccounts = prop([]),
            projectTransfers = prop([]),
            showTaxModal = h.toggleProp(false, true),
            loader = catarse.loaderWithToken,
            listenToReplace = localVnode => {

                const toRedraw = {
                    tax_link: {
                        action: 'onclick',
                        actionSource: () => {
                            showTaxModal.toggle();
                            m.redraw();
                        }
                    }
                };

                _.map(localVnode.dom.children, (item) => {
                    const toR = toRedraw[item.getAttribute('id')];

                    if (toR) {
                        item[toR.action] = toR.actionSource;
                    }
                });
            };


        projectIdVM.project_id(vnode.attrs.project().project_id);

        const lProjectAccount = loader(models.projectAccount.getRowOptions(projectIdVM.parameters()));
        lProjectAccount.load().then((data) => {
            projectAccounts(data);
        });

        const lProjectTransfer = loader(models.projectTransfer.getRowOptions(projectIdVM.parameters()));
        lProjectTransfer.load().then(projectTransfers);

        vnode.state = {
            projectAccounts,
            projectTransfers,
            lProjectAccount,
            lProjectTransfer,
            showTaxModal,
            listenToReplace
        };
    },
    view: function({state, attrs}) {
        const projectAccount = _.first(state.projectAccounts()),
            projectTransfer = _.first(state.projectTransfers()),
            lpa = state.lProjectAccount,
            lpt = state.lProjectTransfer;

        return m('.w-section.section', [
            (state.showTaxModal() ? m(modalBox, {
                displayModal: state.showTaxModal,
                content: [successfulProjectTaxModal, {
                    projectTransfer
                }]
            }) : ''),
            (!lpa() && !lpt() ?
             m('.w-container', [
                 m('.w-row.u-marginbottom-40', [
                     m('.w-col.w-col-6.w-col-push-3', [
                         m('.u-text-center', [
                             m('img.u-marginbottom-20', { src: window.I18n.t('finished.icon', I18nScope()), width: 94 }),
                             m('.fontsize-large.fontweight-semibold.u-marginbottom-20', window.I18n.t('finished.title', I18nScope())),
                             m('.fontsize-base.u-marginbottom-30', {
                                 oncreate: state.listenToReplace
                             }, m.trust(
                                 window.I18n.t('finished.text', I18nScope({ link_news: `/projects/${attrs.project().id}/posts`, link_surveys: `/projects/${attrs.project().id}/surveys` })))),
                             // m('a.btn.btn-large.btn-inline', { href: `/users/${attrs.project().user_id}/edit#balance` }, window.I18n.t('start.cta', I18nScope()))
                         ])
                     ])
                 ])
             ]) : h.loader())

        ]);
    }
};

export default projectSuccessfulOnboard;
