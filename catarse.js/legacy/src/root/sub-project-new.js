import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import models from '../models';
import h from '../h';
import inlineError from '../c/inline-error';

const I18nScope = _.partial(h.i18nScope, 'pages.start');

const subProjectNew = {
    oninit: function(vnode) {
        const categories = prop([]),
            filters = catarse.filtersVM,
            loadCategories = () => models.category.getPage(filters({}).order({
                name: 'asc'
            }).parameters()).then(categories),
            projectCategory = prop('-1'),
            projectName = prop(''),
            projectNameError = prop(false),
            projectCategoryError = prop(false),
            validateProjectForm = () => {
                projectCategoryError(projectCategory() == -1);
                projectNameError(projectName().trim() === '');

                return (!projectCategoryError() && !projectNameError());
            };

        loadCategories();

        vnode.state = {
            categories,
            projectCategory,
            projectName,
            projectNameError,
            projectCategoryError,
            validateProjectForm
        };
    },
    view: function({state}) {
        return m('.before-footer.bg-purple.section-large.u-text-center',
            m('.w-container', [
                m("img[src='https://daks2k3a4ib2z.cloudfront.net/57ba58b4846cc19e60acdd5b/59cd4be2c67c8d0001764fbe_logo-ass.png']"),
                m('.fontcolor-negative.fontsize-large.fontweight-semibold.u-marginbottom-60',
                    'Viva do que você ama fazer'
                ),
                m('.w-row', [
                    m('.w-col.w-col-2'),
                    m('.w-col.w-col-8',
                        m('.w-form', [
                            m('form.w-row.w-form[action="/projects/fallback_create"][method="GET"]',
                                {
                                    onsubmit: e => state.validateProjectForm()
                                }, [
                                    m('.fontcolor-negative.fontsize-larger.u-marginbottom-10',
                                        'Quero iniciar uma campanha chamada'
                                    ),
                                    m('input[name="utf8"][type="hidden"][value="✓"]'),
                                    m(`input[name="authenticity_token"][type="hidden"][value="${h.authenticityToken()}"]`),
                                    m('input.w-hidden[type="text"]', {
                                        name: 'project[mode]',
                                        value: 'sub'
                                    }),
                                    m('input.w-input.text-field.medium.u-marginbottom-30[type="text"]', {
                                        name: 'project[name]',
                                        class: state.projectNameError() ? 'error' : '',
                                        onfocus: () => state.projectNameError(false),
                                        onchange: (e) => {
                                            m.withAttr('value', state.projectName)(e);
                                        }
                                    }),
                                    m('.fontcolor-negative.fontsize-larger.u-marginbottom-10',
                                        'na categoria'
                                    ),
                                    m('select.w-select.text-field.medium.u-marginbottom-40', {
                                        name: 'project[category_id]',
                                        class: state.projectCategoryError() ? 'error' : '',
                                        onfocus: () => state.projectCategoryError(false),
                                        onchange: (e) => {
                                            m.withAttr('value', state.projectCategory)(e);
                                        }
                                    }, [
                                        m('option[value="-1"]', window.I18n.t('form.select_default', I18nScope())),
                                        _.map(state.categories(), category => m('option', {
                                            value: category.id,
                                            selected: state.projectCategory() === category.id
                                        }, category.name))
                                    ])
                                ],
                                m('.u-marginbottom-80.w-row', [
                                    m('.w-col.w-col-4'),
                                    m('.u-margintop-40.w-col.w-col-4',
                                        m(`input[type="submit"][value="${window.I18n.t('form.submit', I18nScope())}"].w-button.btn.btn-large`)
                                    ),
                                    m('.w-col.w-col-4',
                                        m('div')
                                    )
                                ])
                            )
                        ])
                    ),
                    m('.w-col.w-col-2')
                ]),
                m('.w-row.u-marginbottom-80', (state.projectNameError() || state.projectCategoryError()) ? m(inlineError, {
                    message: 'Por favor, verifique novamente os campos acima!'
                }) : ''),

            ])
        );
    }
};

export default subProjectNew;
