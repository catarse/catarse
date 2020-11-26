import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import railsErrorsVM from '../vms/rails-errors-vm';
import projectVideoVM from '../vms/project-video-vm';
import popNotification from './pop-notification';
import inputCard from './input-card';
import projectEditSaveBtn from './project-edit-save-btn';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_video');

const projectBudgetEdit = {
    oninit: function(vnode) {
        const vm = projectVideoVM,
            mapErrors = [
                  ['video_url', ['video_url']],
            ],
            showSuccess = h.toggleProp(false, true),
            showError = h.toggleProp(false, true),
            loading = prop(false),
            onSubmit = (event) => {
                loading(true);
                m.redraw();
                vm.updateProject(vnode.attrs.projectId).then((data) => {
                    loading(false);
                    vm.e.resetFieldErrors();
                    if (!showSuccess()) { showSuccess.toggle(); }
                    if (showError()) { showError.toggle(); }
                    railsErrorsVM.validatePublish();
                }).catch((err) => {
                    if (err.errors_json) {
                        railsErrorsVM.mapRailsErrors(err.errors_json, mapErrors, vm.e);
                    }
                    loading(false);
                    if (showSuccess()) { showSuccess.toggle(); }
                    if (!showError()) { showError.toggle(); }
                });
                return false;
            };

        if (railsErrorsVM.railsErrors()) {
            railsErrorsVM.mapRailsErrors(railsErrorsVM.railsErrors(), mapErrors, vm.e);
        }
        vm.fillFields(vnode.attrs.project);

        vnode.state = {
            onSubmit,
            showSuccess,
            showError,
            vm,
            loading
        };
    },
    view: function({state, attrs}) {
        const vm = state.vm;
        return m('#video-tab', [
            (state.showSuccess() ? m(popNotification, {
                message: window.I18n.t('shared.successful_update'),
                toggleOpt: state.showSuccess
            }) : ''),
            (state.showError() ? m(popNotification, {
                message: window.I18n.t('shared.failed_update'),
                toggleOpt: state.showError,
                error: true
            }) : ''),

            m('form.w-form', { onsubmit: state.onSubmit }, [
                m('.w-container', [
                    m('.w-row', [
                        m('.w-col.w-col-10.w-col-push-1', [
                            m('.u-marginbottom-60.u-text-center', [
		                            m('.w-inline-block.card.fontsize-small.u-radius', [
                                m.trust(window.I18n.t('video_alert', I18nScope()))
		                            ])
	                          ]),
                            m(inputCard, {
                                label: window.I18n.t('video_label', I18nScope()),
                                label_hint: window.I18n.t('video_hint', I18nScope()),
                                children: [
                                    m('input.string.required.w-input.text-field.positive.medium[type="text"]', {
                                        value: vm.fields.video_url(),
                                        class: vm.e.hasError('video_url') ? 'error' : '',
                                        onchange: m.withAttr('value', vm.fields.video_url)
                                    }),
                                    vm.e.inlineError('video_url')
                                ]
                            })
                        ])
                    ])
                ]),
                m(projectEditSaveBtn, { loading: state.loading, onSubmit: state.onSubmit })
            ])

        ]);
    }
};

export default projectBudgetEdit;
