/**
 * window.c.projectReport component
 * Render project report form
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import projectVM from '../vms/project-vm';
import inlineError from './inline-error';
import projectReportDisrespectRules from './project-report-disrespect-rules';
import projectReportInfringesIntellectualProperty from './project-report-infringes-intellectual-property';
import projectReportNoRewardReceived from './project-report-no-reward-received';

const projectReport = {
    oninit: function(vnode) {
        const displayForm = h.toggleProp(false, true),
            displayFormWithName = prop(''),
            sendSuccess = prop(false),
            submitDisabled = prop(false),
            user = vnode.attrs && vnode.attrs.user ? vnode.attrs.user : (h.getUser() || {}),
            email = prop(user.email),
            details = prop(''),
            reason = prop(''),
            storeReport = 'report',
            project = vnode.attrs && vnode.attrs.project ? vnode.attrs.project : projectVM.currentProject(),
            hasPendingAction = project && (h.callStoredAction(storeReport) == project.project_id),
            CPF = prop(''),
            telephone = prop(''),
            businessName = prop(''),
            CNPJ = prop(''),
            businessRole = prop(''),
            relationWithViolatedProperty = prop(''),
            fullName = prop(''),
            fullAddress = prop(''),
            projectInfringes = prop(''),
            termsAgreed = h.toggleProp(false, true),
            checkLogin = (event) => {
                if (!_.isEmpty(user)) {
                    displayForm.toggle();
                } else {
                    h.storeAction(storeReport, project.project_id);
                    return h.navigateToDevise(`?redirect_to=/projects/${project.project_id}`);
                }
            },
            sendReport = (validateFunction) => {
                if (!validateFunction()) {
                    return false;
                }
                submitDisabled(true);
                const loaderOpts = models.projectReport.postOptions({
                    email: email(),
                    details: details(),
                    reason: reason(),
                    data: {
                        email: email(),
                        details: details(),
                        reason: reason(),
                        cpf: CPF(),
                        telephone: telephone(),
                        business_name: businessName(),
                        cnpj: CNPJ(),
                        business_role: businessRole(),
                        relation_with_violated_property: relationWithViolatedProperty(),
                        full_name: fullName(),
                        project_infringes: projectInfringes(),
                        terms_agreed: termsAgreed(),
                    },
                    project_id: project.project_id
                });
                const l = catarse.loaderWithToken(loaderOpts);

                l.load().then(sendSuccess(true));
                submitDisabled(false);
                return false;
            },
            checkScroll = (localVnode) => {
                h.animateScrollTo(localVnode.dom);
            };


        if (!_.isEmpty(user) && hasPendingAction) {
            displayForm(true);
        }

        vnode.state = {
            displayFormWithName,
            checkScroll,
            checkLogin,
            displayForm,
            sendSuccess,
            submitDisabled,
            sendReport,
            user,
            details,
            reason,
            project: prop(project),
            user,
            CPF,
            telephone,
            businessName,
            CNPJ,
            businessRole,
            relationWithViolatedProperty,
            fullName,
            fullAddress,
            projectInfringes,
            termsAgreed
        };
    },

    view: function({state, attrs}) {
        return m('.card.card-terciary.u-radius', [
            state.sendSuccess() ?
                    m('.w-form', m('p', 'Obrigado! A sua denúncia foi recebida.'))
                :
            [
                m('button.btn.btn-terciary.btn-inline.btn-medium.w-button',
                    {
                        onclick: state.checkLogin
                    },
                          'Denunciar este projeto ao Catarse'
                        ),
                state.displayForm() ?
                            m('div', [
                                m(projectReportDisrespectRules, {
                                    displayFormWithName: state.displayFormWithName,
                                    submitDisabled: state.submitDisabled,
                                    checkScroll: state.checkScroll,
                                    sendReport: state.sendReport,
                                    reason: state.reason,
                                    details: state.details,
                                }),
                                m(projectReportInfringesIntellectualProperty, {
                                    CPF: state.CPF,
                                    telephone: state.telephone,
                                    businessName: state.businessName,
                                    CNPJ: state.CNPJ,
                                    businessRole: state.businessRole,
                                    relationWithViolatedProperty: state.relationWithViolatedProperty,
                                    fullName: state.fullName,
                                    fullAddress: state.fullAddress,
                                    projectInfringes: state.projectInfringes,
                                    termsAgreed: state.termsAgreed,
                                    reason: state.reason,
                                    details: state.details,
                                    displayFormWithName: state.displayFormWithName,
                                    sendReport: state.sendReport,
                                    checkScroll: state.checkScroll,
                                    submitDisabled: state.submitDisabled
                                }),
                                m(projectReportNoRewardReceived, {
                                    displayFormWithName: state.displayFormWithName,
                                    project: state.project,
                                    user: state.user
                                })
                            ])
                        :
                            ''
            ]
        ]);
    }
};

export default projectReport;
