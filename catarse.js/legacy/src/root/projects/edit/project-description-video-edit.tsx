import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../../../h';
import railsErrorsVM from '../../../vms/rails-errors-vm';
import projectDescriptionVideoVM from '../../../vms/project-description-video-vm';
import PopNotification from '../../../c/pop-notification';
import InputCard from '../../../c/input-card';
import BigInputCard from '../../../c/big-input-card';
import ProjectEditSaveBtn from '../../../c/project-edit-save-btn';
import { I18nText } from '../../../shared/components/i18n-text';
import TextEditor from '../../../shared/components/text-editor';
import { HTMLInputEvent } from '../../../entities';

const projectDescriptionVideoEdit = {
    oninit: function (vnode) {
        const vm = projectDescriptionVideoVM,
            mapErrors = [
                ['about_html', ['about_html']],
                ['video_url', ['video_url']]
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
        const scopeVideo = 'projects.dashboard_video'
        const videoClass = vm.e.hasError('video_url') ? 'error' : ''
        const videoError = vm.e.inlineError('video_url')
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
                                    <div class="w-col-8 w-inline-block card fontsize-small u-radius">
                                        <I18nText
                                            trust={true}
                                            scope={`${scope}.description_video_alert`} />
                                    </div>
                                </div>
                                <InputCard
                                    label={
                                        <I18nText trust={true} scope={`${scopeVideo}.video_label`} />
                                    }
                                    label_hint={
                                        <I18nText trust={true} scope={`${scopeVideo}.video_hint`} />
                                    }
                                >
                                    <input
                                        value={vm.fields.video_url()}
                                        onchange={(event : HTMLInputEvent) => vm.fields.video_url(event.target.value)}
                                        type="text"
                                        class={`${videoClass} string required w-input text-field positive medium`} />
                                    {videoError}
                                </InputCard>
                            </div>
                        </div>
                        <div class="w-row">
                            <div class="w-col w-col-10 w-col-push-1">
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
                        onSubmit={state.onSubmit} />
                </form>
            </div>
        )
    }
};

export default projectDescriptionVideoEdit;
