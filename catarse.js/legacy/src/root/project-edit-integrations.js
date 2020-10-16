import m from 'mithril';
import Stream from 'mithril/stream';
import _ from 'underscore';
import h, { VNode } from '../h';
import projectVM, { ProjectIntegration } from '../vms/project-vm';
import projectEditSaveBtn from '../c/project-edit-save-btn';
import railsErrorsVM from '../vms/rails-errors-vm';
import popNotification from '../c/pop-notification';

const GA = 'GA';
const PIXEL = 'PIXEL';

export class ProjectEditIntegrations {

    oninit(/** @type {VNode} */vnode) {
         
        /**
         * @param {string} name
         * @param {ProjectIntegration[]} integrations
         * @returns {ProjectIntegration} 
         * */
        const findIntegrationByName = (name = '', integrations = []) => integrations.find(integration => integration.name === name);

        const GATracking = h.RedrawStream({ data: { id: '' }, name: GA });
        const FBPixelTracking = h.RedrawStream({ data: { id: '' }, name: PIXEL });

        const GATrackingID = h.RedrawStream('', id => {
            GATracking(_.extend(GATracking(), { data: { id }, name: GA }));
        });
        const FBPixelTrackingID = h.RedrawStream('', id => {
            FBPixelTracking(_.extend(FBPixelTracking(), { data: { id }, name: PIXEL }));
        });

        const loadingIntegrations = h.RedrawStream(true);
        const loading = h.RedrawStream(false);
        const error = h.RedrawStream(false);
        const showSuccess = h.RedrawStream(false);
        const showError = h.RedrawStream(false);
        const projectId = vnode.attrs.project_id;

        projectVM
            .getIntegrations(projectId)
            .then(data => {
                GATrackingID(GATracking(findIntegrationByName(GA, data)).data.id);
                FBPixelTrackingID(FBPixelTracking(findIntegrationByName(PIXEL, data)).data.id);
                loadingIntegrations(false);
            })
            .catch(error => {
                loadingIntegrations(false);
            });
        
        /**
         * @param {Stream<ProjectIntegration>} integration 
         */
        async function requestForIntegration(integration) {
            const integrationData = integration();
            const shouldCreate = !!integrationData.id;

            const response = shouldCreate ? 
                await projectVM.updateIntegration(projectId, integrationData)
            :
                await projectVM.createIntegration(projectId, integrationData);

            integrationData.id = response.integration_id;
            integration(integrationData);
        }

        async function save() {
            loading(true);
            try {
                showError(false);
                error(false);

                await requestForIntegration(GATracking);
                await requestForIntegration(FBPixelTracking);
                
                showSuccess(true);
            } catch(e) {
                error(true);
                showError(true);
            }
            loading(false);
        }

        vnode.state = {
            GATrackingID,
            FBPixelTrackingID,
            loading,
            save,
            error,
            showSuccess,
            showError,
            loadingIntegrations
        };
    }

    view({ state, attrs }) {

        const GATrackingID = state.GATrackingID;
        const FBPixelTrackingID = state.FBPixelTrackingID;
        const save = state.save;
        const error = state.error;
        const showSuccess = state.showSuccess;
        const showError = state.showError;
        const loadingIntegrations = state.loadingIntegrations;

        if (loadingIntegrations()) {
            return h.loader();
        } else {
            return m('#integrations', [
                (state.showSuccess() ? m(popNotification, {
                    message: window.I18n.t('shared.successful_update'),
                    toggleOpt: state.showSuccess
                }) : ''),
                (state.showError() ? m(popNotification, {
                    message: window.I18n.t('shared.failed_update'),
                    toggleOpt: state.showError,
                    error: true
                }) : ''),
                
                m('div.section',
                    m('div.w-container',
                        m('div.w-row', [
                            m('div.w-col.w-col-1'),
                            m('div.w-col.w-col-10',
                                m('div.w-form', [
                                    m('form', [
                                        m('div.u-marginbottom-20.card.card-terciary.medium.w-row', [
                                            m('div.w-col.w-col-5', [
                                                m('label.fontweight-semibold.fontsize-base', 'Google Analytics'),
                                                m('label.field-label.fontsize-smallest.fontcolor-secondary', [
                                                    'Informe o seu ID de Acompanhamento e comece a enviar informações dos visitantes de sua página para a sua conta do Google Analytics ',
                                                    m('a.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360038491812"]', 'Saiba mais')
                                                ]),
                                                m('img[src="/assets/logo_lockup_analytics_icon_horizontal_black.png"][width="146"][alt=""]')
                                            ]),
                                            m('div.w-col.w-col-7',
                                                m('div.w-row', [
                                                    m('div.text-field.prefix.no-hover.medium.prefix-permalink.w-col.w-col-2.w-col-tiny-2',
                                                        m('div.fontcolor-secondary.u-text-center.fontsize-smallest', 'UA-')
                                                    ),
                                                    m('div.w-col.w-col-10.w-col-tiny-10',
                                                        m(`input${error() ? '.error' : ''}.text-field.postfix.positive.medium.w-input[type="text"][placeholder="1234567-1"][id="google-analytics-id"]`, {
                                                            value: GATrackingID(),
                                                            onkeyup: (/** @type {Event} */ event) => GATrackingID(event.target.value)
                                                        }),
                                                    )
                                                ])
                                            )
                                        ]),
                                        m('div.u-marginbottom-20.card.card-terciary.medium.w-row', [
                                            m('div.w-col.w-col-5', [
                                                m('label.fontweight-semibold.fontsize-base', 'Facebook Pixel'),
                                                    m('label.field-label.fontsize-smallest.fontcolor-secondary', [
                                                        'Envia informações dos visitantes de sua página para o seu Facebook Pixel ',
                                                        m('a.alt-link[href="https://suporte.catarse.me/hc/pt-br/articles/360038491672"]', 'Saiba mais')
                                                    ]),
                                                    m('img[src="/assets/facebook-pixel-logotyp.png"][width="146"][alt=""]')
                                            ]),
                                            m('div.w-col.w-col-7', [
                                                m(`input${error() ? '.error' : ''}.text-field.medium.positive.w-input[type="text"][placeholder="123456789123456"][id="fb-pixel-id"]`, {
                                                    value: FBPixelTrackingID(),
                                                    onkeyup: (/** @type {Event} */ event) => FBPixelTrackingID(event.target.value.replace(/\D*/g, ''))
                                                }),
                                            ])
                                        ])
                                    ]),
                                ])
                            ),
                        ])
                    ),
        
                    m(projectEditSaveBtn, { loading: state.loading, onSubmit: save }),
                )
            ]);
        }
    }
}
