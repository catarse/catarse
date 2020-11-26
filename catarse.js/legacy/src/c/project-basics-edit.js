import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import railsErrorsVM from '../vms/rails-errors-vm';
import projectBasicsVM from '../vms/project-basics-vm';
import popNotification from './pop-notification';
import inputCard from './input-card';
import projectEditSaveBtn from './project-edit-save-btn';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_basics');

const ADULT_CONTENT_AGE = 18;
const NO_ADULT_CONTENT_AGE = 1;
const CONTENT_RATING_NOT_SET = 0;

const projectBasicsEdit = {
    oninit: function (vnode) {
        const vm = projectBasicsVM,
            mapErrors = [
                ['name', ['name']],
                ['public_tags', ['public_tags']],
                ['content_rating', ['content_rating']],
                ['permalink', ['permalink']],
                ['category_id', ['category']],
                ['city_id', ['city']],
            ],
            loading = prop(false),
            cities = prop(),
            categories = prop([]),
            isAdultContent = prop(null),
            showSuccess = h.toggleProp(false, true),
            showError = h.toggleProp(false, true),
            selectedTags = prop([]),
            tagOptions = prop([]),
            isEditingTags = prop(false),
            tagEditingLoading = prop(false),
            onSubmit = () => {
                if (isEditingTags()) {
                    return false;
                }

                loading(true);
                m.redraw();
                const tagString = _.pluck(selectedTags(), 'name').join(',');
                vm.fields.public_tags(tagString);
                vm.updateProject(vnode.attrs.projectId)
                    .then(() => {
                        loading(false);
                        vm.e.resetFieldErrors();
                        showSuccess(true);
                        showError(false);
                        vnode.attrs.reloadProject(vm.fillFields);
                    })
                    .catch(err => {
                        if (err.errors_json) {
                            railsErrorsVM.mapRailsErrors(err.errors_json, mapErrors, vm.e);
                        }
                        loading(false);
                        showSuccess(false);
                        showError(true);
                    });

                return false;
            };
        if (railsErrorsVM.railsErrors()) {
            railsErrorsVM.mapRailsErrors(railsErrorsVM.railsErrors(), mapErrors, vm.e);
        }
        vm.fillFields(vnode.attrs.project);

        if (vm.fields.public_tags()) {
            selectedTags(_.map(vm.fields.public_tags().split(','), name => ({ name })));
        }

        vm.loadCategoriesOptionsTo(categories, vm.fields.category_id());
        const addTag = tag => () => {
            tagOptions([]);

            if (selectedTags().length >= 5) {
                vm.e('public_tags', window.I18n.t('tags_max_error', I18nScope()));
                vm.e.inlineError('public_tags', true);
                m.redraw();

                return false;
            }
            selectedTags().push(tag);
            isEditingTags(false);

            m.redraw();

            return false;
        };

        const removeTag = tagToRemove => () => {
            const updatedTags = _.reject(selectedTags(), tag => tag === tagToRemove);

            selectedTags(updatedTags);

            return false;
        };
        const tagString = prop('');
        const transport = prop({ abort: Function.prototype });
        const searchTagsUrl = `${h.getApiHost()}/rpc/tag_search`;
        const searchTags = () => m.request({ method: 'POST', background: true, config: transport, data: { query: tagString(), count: 3 }, url: searchTagsUrl });
        const triggerTagSearch = e => {
            tagString(e.target.value);

            isEditingTags(true);
            tagOptions([]);

            const keyCode = e.keyCode;

            if (keyCode === 188 || keyCode === 13) {
                const tag = tagString().charAt(tagString().length - 1) === ',' ? tagString().substr(0, tagString().length - 1) : tagString();

                addTag({ name: tag.toLowerCase() }).call();
                e.target.value = '';
                return false;
            }

            tagEditingLoading(true);
            transport().abort();
            searchTags().then(data => {
                tagOptions(data);
                tagEditingLoading(false);
                m.redraw(true);
            });

            return false;
        };

        const editTag = event => {
            return triggerTagSearch(event);
        };

        vnode.state = {
            vm,
            isAdultContent,
            onSubmit,
            loading,
            categories,
            cities,
            showSuccess,
            showError,
            tagOptions,
            editTag,
            addTag,
            removeTag,
            isEditingTags,
            triggerTagSearch,
            selectedTags,
            tagEditingLoading,
        };
    },
    view: function ({ state, attrs }) {
        const vm = state.vm;

        return m('#basics-tab', [
            state.showSuccess()
                ? m(popNotification, {
                    message: window.I18n.t('shared.successful_update'),
                    toggleOpt: state.showSuccess,
                })
                : '',
            state.showError()
                ? m(popNotification, {
                    message: window.I18n.t('shared.failed_update'),
                    toggleOpt: state.showError,
                    error: true,
                })
                : '',
            // add pop notifications here
            m('form.w-form', { onsubmit: state.onSubmit }, [
                m('.w-container', [
                    // admin fields
                    attrs.user.is_admin
                        ? m('.w-row', [
                            m('.w-col.w-col-10.w-col-push-1', [
                                m(inputCard, {
                                    label: window.I18n.t('tracker_snippet_html', I18nScope()),
                                    children: [
                                        m('textarea.text.optional.w-input.text-field.positive.medium', {
                                            value: vm.fields.tracker_snippet_html(),
                                            onchange: m.withAttr('value', vm.fields.tracker_snippet_html),
                                        }),
                                    ],
                                }),
                                m(inputCard, {
                                    label: window.I18n.t('user_id', I18nScope()),
                                    children: [
                                        m('input.string.optional.w-input.text-field.positive.medium[type="text"]', {
                                            value: vm.fields.user_id(),
                                            onchange: m.withAttr('value', vm.fields.user_id),
                                        }),
                                    ],
                                }),
                                m(inputCard, {
                                    label: window.I18n.t('admin_tags', I18nScope()),
                                    label_hint: window.I18n.t('admin_tags_hint', I18nScope()),
                                    children: [
                                        m('input.string.optional.w-input.text-field.positive.medium[type="text"]', {
                                            value: vm.fields.admin_tags(),
                                            onchange: m.withAttr('value', vm.fields.admin_tags),
                                        }),
                                    ],
                                }),
                                m(inputCard, {
                                    label: window.I18n.t('service_fee', I18nScope()),
                                    children: [
                                        m('input.string.optional.w-input.text-field.positive.medium[type="number"]', {
                                            value: vm.fields.service_fee(),
                                            onchange: m.withAttr('value', vm.fields.service_fee),
                                        }),
                                    ],
                                }),

                                m(inputCard, {
                                    label: window.I18n.t('solidarity_covid', I18nScope()),
                                    children: [
                                        m('select.required.w-input.text-field.w-select.positive.medium', {
                                            value: `${vm.fields.is_solidarity()}`,
                                            class: vm.e.hasError('integrations') ? 'error' : '',
                                            onchange: m.withAttr('value', (value) => vm.fields.is_solidarity(JSON.parse(value))),
                                        }, [
                                            m(`option[value=true]`, {
                                                selected: vm.fields.is_solidarity(),
                                            }, 'Sim'),
                                            m(`option[value=false]`, {
                                                selected: !vm.fields.is_solidarity(),
                                            }, 'Não')
                                        ]),
                                        vm.e.inlineError('integrations'),
                                    ]
                                })
                            ]),
                        ])
                        : '',
                    m('.w-row', [
                        m('.w-col.w-col-10.w-col-push-1', [
                            m(inputCard, {
                                label: window.I18n.t('name', I18nScope()),
                                label_hint: window.I18n.t('name_hint', I18nScope()),
                                children: [
                                    m('input.string.required.w-input.text-field.positive.medium[type="text"][maxlength="50"]', {
                                        value: vm.fields.name(),
                                        class: vm.e.hasError('name') ? 'error' : '',
                                        onchange: m.withAttr('value', vm.fields.name),
                                    }),
                                    vm.e.inlineError('name'),
                                ],
                            }),
                            m(inputCard, {
                                label: window.I18n.t('adult_content', I18nScope()),
                                label_hint: window.I18n.t('adult_content_hint', I18nScope()),
                                children: [
                                    m(
                                        'select.required.w-input.text-field.w-select.positive.medium[id="content_rating_id"]',
                                        {
                                            value: vm.fields.content_rating(),
                                            class: vm.e.hasError('content_rating') ? 'error' : '',
                                            onchange: (event) => {
                                                try {
                                                    const content_rating_value = JSON.parse(event.target.value);
                                                    vm.fields.content_rating(content_rating_value);
                                                    vm.fields.show_cans_and_cants(content_rating_value === ADULT_CONTENT_AGE);
                                                    vm.fields.force_show_cans_and_cants(false);
                                                } catch (e) {
                                                    console.log('Error setting content rating:', e);
                                                    h.captureException(e);
                                                }
                                            },
                                        },
                                        m(`option[value=${CONTENT_RATING_NOT_SET}]`, {
                                            selected: vm.fields.content_rating() === CONTENT_RATING_NOT_SET
                                        }, I18n.t('is_adult_content_answer_choose', I18nScope())),
                                        m(`option[value=${ADULT_CONTENT_AGE}]`, {
                                            selected: vm.fields.content_rating() === ADULT_CONTENT_AGE
                                        }, I18n.t('is_adult_content_answer_yes', I18nScope())),
                                        m(`option[value=${NO_ADULT_CONTENT_AGE}]`, {
                                            selected: vm.fields.content_rating() === NO_ADULT_CONTENT_AGE
                                        }, I18n.t('is_adult_content_answer_no', I18nScope()))
                                    ),
                                    vm.e.inlineError('content_rating'),

                                    m('div.fontsize-smaller.fontweight-light.fontcolor-secondary', [
                                        window.I18n.t('adult_content_description', I18nScope()),
                                        m('a.alt-link.fontweight-semibold', {
                                            onclick: () => vm.fields.force_show_cans_and_cants.toggle()
                                        }, window.I18n.t('adult_content_description_click_more', I18nScope()) ),
                                        '.'
                                    ])
                                ],
                                belowChildren: (vm.fields.show_cans_and_cants() || vm.fields.force_show_cans_and_cants()) && [
                                    m('div.card.u-margintop-30', [
                                        m('.w-row', [
                                            m('div.w-sub-col.w-col.w-col-6', [
                                                m('div.fontsize-small.fontweight-semibold.u-marginbottom-10', I18n.t('adult_content_can_title', I18nScope())),
                                                m('div.fontsize-smaller', I18n.t('adult_content_can_text', I18nScope()))
                                            ]),
                                            m('div.w-col.w-col-6', [
                                                m('div.fontsize-small.fontweight-semibold.u-marginbottom-10', I18n.t('adult_content_cant_title', I18nScope())),
                                                m('div.fontsize-smaller', [
                                                    m.trust(I18n.t('adult_content_cant_text', I18nScope()))
                                                ])
                                            ])
                                        ]),
                                        m('div.fontsize-small.u-text-center.u-margintop-30.u-marginbottom-20',
                                            m(`a.alt-link.fontweight-semibold[target="_blank"][href="${I18n.t('adult_content_support_url', I18nScope())}"]`,
                                                I18n.t('adult_content_more_info_link_text', I18nScope())
                                            )
                                        )
                                    ])
                                ]
                            }),
                            m(inputCard, {
                                label: window.I18n.t('tags', I18nScope()),
                                label_hint: window.I18n.t('tags_hint', I18nScope()),
                                onclick: () => state.isEditingTags(false),
                                children: [
                                    m('input.string.optional.w-input.text-field.positive.medium[type="text"]', {
                                        onkeyup: event => state.editTag(event),
                                        class: vm.e.hasError('public_tags') ? 'error' : '',
                                        onfocus: () => vm.e.inlineError('public_tags', false),
                                    }),
                                    state.isEditingTags()
                                        ? m(
                                            '.options-list.table-outer',
                                            state.tagEditingLoading()
                                                ? m('.dropdown-link', m('.fontsize-smallest', 'Carregando...'))
                                                : state.tagOptions().length
                                                    ? _.map(state.tagOptions(), tag =>
                                                        m('.dropdown-link', { onclick: state.addTag(tag) }, m('.fontsize-smaller', tag.name))
                                                    )
                                                    : m('.dropdown-link', m('.fontsize-smallest', 'Nenhuma tag relacionada...'))
                                        )
                                        : '',
                                    vm.e.inlineError('public_tags'),
                                    m(
                                        'div.tag-choices',
                                        _.map(state.selectedTags(), choice =>
                                            m(
                                                '.tag-div',
                                                m('div', [m('a.tag-close-btn.fa.fa-times-circle', { onclick: state.removeTag(choice) }), ` ${choice.name}`])
                                            )
                                        )
                                    ),
                                ],
                            }),
                            m(inputCard, {
                                label: window.I18n.t('permalink', I18nScope()),
                                label_hint: window.I18n.t('permalink_hint', I18nScope()),
                                children: [
                                    m('.w-row', [
                                        m(
                                            '.w-col.w-col-4.w-col-small-6.w-col-tiny6.text-field.prefix.no-hover.medium.prefix-permalink',
                                            {
                                                class: vm.e.hasError('permalink') ? 'error' : '',
                                            },
                                            m('.fontcolor-secondary.u-text-center.fontcolor-secondary.u-text-center.fontsize-smallest', 'www.catarse.me/')
                                        ),
                                        m('.w-col.w-col-8.w-col-small-6.w-col-tiny-6', [
                                            m('input.string.required.w-input.text-field.postfix.positive.medium[type="text"]', {
                                                value: vm.fields.permalink(),
                                                class: vm.e.hasError('permalink') ? 'error' : '',
                                                onchange: m.withAttr('value', vm.fields.permalink),
                                            }),
                                        ]),
                                    ]),
                                    m('.w-row', vm.e.inlineError('permalink')),
                                ],
                            }),
                            m(inputCard, {
                                label: window.I18n.t('category', I18nScope()),
                                label_hint: window.I18n.t('category_hint', I18nScope()),
                                children: [
                                    m(
                                        'select.required.w-input.text-field.w-select.positive.medium',
                                        {
                                            value: vm.fields.category_id(),
                                            class: vm.e.hasError('category_id') ? 'error' : '',
                                            onchange: m.withAttr('value', vm.fields.category_id),
                                        },
                                        state.categories()
                                    ),
                                    vm.e.inlineError('category_id'),
                                ],
                            }),
                            m(inputCard, {
                                label: window.I18n.t('city', I18nScope()),
                                label_hint: window.I18n.t('city_hint', I18nScope()),
                                children: [
                                    m('input.string.required.w-input.text-field.positive.medium[type="text"]', {
                                        value: vm.fields.city_name(),
                                        class: vm.e.hasError('city_id') ? 'error' : '',
                                        onkeyup: vm.generateSearchCity(state.cities),
                                    }),
                                    vm.e.inlineError('city_id'),
                                    state.cities(),
                                ],
                            }),
                        ]),
                    ]),
                ]),
                m(projectEditSaveBtn, { loading: state.loading, onSubmit: state.onSubmit }),
            ]),
        ]);
    },
};

export default projectBasicsEdit;
