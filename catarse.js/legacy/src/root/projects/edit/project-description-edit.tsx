import m from 'mithril'
import prop from 'mithril/stream'
import _ from 'underscore'
import h from '../../../h'
import railsErrorsVM from '../../../vms/rails-errors-vm'
import projectDescriptionVM from '../../../vms/project-description-vm'
import PopNotification from '../../../c/pop-notification'
import BigInputCard from '../../../c/big-input-card'
import ProjectEditSaveBtn from '../../../c/project-edit-save-btn'
import TextEditor from '../../../shared/components/text-editor'
import { I18nText } from '../../../shared/components/i18n-text'
import { ThisWindow } from '../../../entities'

declare var window : ThisWindow

const projectDescriptionEdit = {
    oninit: function (vnode) {
        const vm = projectDescriptionVM,
            mapErrors = [
                ['about_html', ['about_html']],
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
    view: function ({ state, attrs }) {
        const vm = state.vm;
        const scope = 'projects.dashboard_description'
        const aboutHtmlClass = vm.e.hasError('about_html') ? 'error' : ''
        const aboutHtmlError = vm.e.inlineError('about_html')
        return (
            <div id="description-tab">
                {
                    state.showSuccess() &&
                    <PopNotification
                        message={window.I18n.t('shared.successful_update')}
                        toggleOpt={state.showSuccess} />
                }
                {
                    state.showError() &&
                    <PopNotification
                        message={window.I18n.t('shared.failed_update')}
                        toggleOpt={state.showError}
                        error={true} />
                }
                <form onsubmit={state.onSubmit} class="w-form">
                    <div class="w-container">
                        <div class="w-row">
                            <div class="w-col w-col-10 w-col-push-1">
                                <div class="u-marginbottom-60 u-text-center">
                                    <div class="w-inline-block card fontsize-small u-radius">
                                        <I18nText
                                            trust={true}
                                            scope={`${scope}.description_alert`} />
                                    </div>
                                </div>

                                <BigInputCard
                                    label={
                                        <I18nText trust={true} scope={`${scope}.description_label`} />
                                    }
                                    label_hint={
                                        <I18nText trust={true} scope={`${scope}.description_hint`} />
                                    }
                                >
                                    <div class={`${aboutHtmlClass} preview-container`}>
                                        <TextEditor
                                            name={'project[about_html]'}
                                            value={vm.fields.about_html()}
                                            onChange={vm.fields.about_html}
                                            />
                                        {aboutHtmlError}
                                    </div>
                                </BigInputCard>
                            </div>
                        </div>
                    </div>
                    <ProjectEditSaveBtn
                        loading={state.loading}
                        onSubmit={state.onSubmit}/>
                </form>
            </div>
        )
    }
};

export default projectDescriptionEdit;
