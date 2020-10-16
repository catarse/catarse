import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import railsErrorsVM from '../vms/rails-errors-vm';
import projectCardVM from '../vms/project-card-vm';
import popNotification from './pop-notification';
import inputCard from './input-card';
import projectEditSaveBtn from './project-edit-save-btn';
import projectCard from './project-card';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_card');

const projectCardEdit = {
    oninit: function(vnode) {
        const vm = projectCardVM,
            mapErrors = [
                ['uploaded_image', ['uploaded_image']],
                ['cover_image', ['cover_image']],
                ['headline', ['headline']],
            ],
            showSuccess = h.toggleProp(false, true),
            showError = h.toggleProp(false, true),
            loading = prop(false),
            onSubmit = () => {
                loading(true);
                m.redraw();
                vm.uploadImage(vnode.attrs.projectId).then(() => {
                    vm.updateProject(vnode.attrs.projectId).then(() => {
                        loading(false);
                        vm.e.resetFieldErrors();
                        if (!showSuccess()) { showSuccess.toggle(); }
                        if (showError()) { showError.toggle(); }
                        vm.reloadCurrentProject();
                        railsErrorsVM.validatePublish();
                    }).catch((err) => {
                        if (err.errors_json) {
                            railsErrorsVM.mapRailsErrors(err.errors_json, mapErrors, vm.e);
                        }
                        loading(false);
                        if (showSuccess()) { showSuccess.toggle(); }
                        if (!showError()) { showError.toggle(); }
                        m.redraw();
                    });
                }).catch((uploaderr) => {
                    if (uploaderr.errors_json) {
                        railsErrorsVM.mapRailsErrors(uploaderr.errors_json, mapErrors, vm.e);
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
    view: function({ state }) {
        const vm = state.vm;
        return m('#card-tab', [
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
                m('.w-section.section', [
                    m('.w-container', [
                        (
                            vm.currentProject().mode === 'sub' ?
                                m('.w-row', [
                                    m('.w-col.w-col-12', [
                                        m(inputCard, {
                                            label: m.trust(window.I18n.t('cover_image_label', I18nScope())),
                                            label_hint: window.I18n.t('cover_image_hint', I18nScope()),
                                            children: [
                                                m('span.hint',
                                                    (vm.fields.cover_image()
                                                        ? m(`img[alt="Imagem de fundo"][src="${vm.fields.cover_image()}"]`)
                                                        : 'Imagem de fundo')
                                                ),
                                                m('input.file.optional.w-input.text-field[id="project_cover_image"][name="project[cover_image]"][type="file"]', {
                                                    class: vm.e.hasError('cover_image') ? 'error' : false,
                                                    onchange: (e) => { vm.prepareForUpload(e, 'cover_image'); }
                                                }),
                                                vm.e.inlineError('cover_image')
                                            ]
                                        })
                                    ])
                                ])
                                : 
                                ''
                        ),
                        m('.w-row', [
                            m('.w-col.w-col-8', [
                                m(inputCard, {
                                    label: window.I18n.t('uploaded_image_label', I18nScope()),
                                    label_hint: window.I18n.t('uploaded_image_hint', I18nScope()),
                                    children: [
                                        m('input.file.optional.w-input.text-field[id="project_uploaded_image"][name="project[uploaded_image]"][type="file"]', {
                                            class: vm.e.hasError('uploaded_image') ? 'error' : false,
                                            onchange: (e) => { vm.prepareForUpload(e, 'uploaded_image'); }
                                        }),
                                        vm.e.inlineError('uploaded_image')
                                    ]
                                }),
                                m(inputCard, {
                                    label: window.I18n.t('headline_label', I18nScope()),
                                    label_hint: window.I18n.t('headline_label_hint', I18nScope()),
                                    children: [
                                        m('textarea.text.optional.w-input.text-field.positive[id="project_headline"][maxlength="100"][name="project[headline]"][rows="3"]', {
                                            onchange: m.withAttr('value', vm.fields.headline),
                                            class: vm.e.hasError('headline') ? 'error' : false
                                        }, vm.fields.headline()),
                                        vm.e.inlineError('headline')
                                    ]
                                })
                            ]),
                            m(projectCard, { project: vm.currentProject(), type: 'small' })
                        ])
                    ])
                ]),
                m(projectEditSaveBtn, { loading: state.loading, onSubmit: state.onSubmit })
            ])

        ]);
    }
};

export default projectCardEdit;
