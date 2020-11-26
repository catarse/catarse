import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import _ from 'underscore';
import models from '../models';
import h from '../h';
import startVM from '../vms/start-vm';
import youtubeLightbox from '../c/youtube-lightbox';
import slider from '../c/slider';
import landingQA from '../c/landing-qa';
import inlineError from '../c/inline-error';

const I18nScope = _.partial(h.i18nScope, 'pages.start');

const start = {
    oninit: function(vnode) {
        h.analytics.windowScroll({ cat: 'project_start', act: 'start_page_scroll' });
        const stats = prop([]),
            categories = prop([]),
            selectedPane = prop(0),
            selectedCategory = prop([]),
            featuredProjects = prop([]),
            selectedCategoryIdx = prop(-1),
            startvm = startVM(window.I18n),
            filters = catarse.filtersVM,
            paneImages = startvm.panes,
            categoryvm = filters({
                category_id: 'eq'
            }),
            projectvm = filters({
                project_id: 'eq'
            }),
            uservm = filters({
                id: 'eq'
            }),
            loader = catarse.loader,
            statsLoader = loader(models.statistic.getRowOptions()),
            loadCategories = () => models.category.getPage(filters({}).order({
                name: 'asc'
            }).parameters()).then(categories),
            selectPane = idx => () => {
                selectedPane(idx);
            },
            lCategory = () => loader(models.categoryTotals.getRowOptions(categoryvm.parameters())),
            lProject = () => loader(models.projectDetail.getRowOptions(projectvm.parameters())),
            lUser = () => loader(models.userDetail.getRowOptions(uservm.parameters())),
            linkToExternal = (category) => {
                const externalLinkCategories = window.I18n.translations[window.I18n.currentLocale()].projects.index.explore_categories;
                return _.isUndefined(externalLinkCategories[category.id])
                    ? null
                    : `${externalLinkCategories[category.id].link}?ref=ctrse_start`;
            },
            loadCategoryProjects = (category) => {
                selectedCategory(category);
                const categoryProjects = _.findWhere(startvm.categoryProjects, {
                    categoryId: _.first(category).category_id
                });
                featuredProjects([]);
                if (!_.isUndefined(categoryProjects)) {
                    _.map(categoryProjects.sampleProjects, (project_id, idx) => {
                        if (!_.isUndefined(project_id)) {
                            projectvm.project_id(project_id);
                            lProject().load().then(project => setProject(project, idx));
                        }
                    });
                }
            },
            selectCategory = category => () => {
                const externalLink = linkToExternal(category);
                if (externalLink) {
                    window.location = externalLink;
                    return;
                }
                selectedCategoryIdx(category.id);
                categoryvm.category_id(category.id);
                selectedCategory([category]);
                m.redraw();
                lCategory().load().then(loadCategoryProjects);
            },
            setUser = (user, idx) => {
                featuredProjects()[idx] = _.extend({}, featuredProjects()[idx], {
                    userThumb: _.first(user).profile_img_thumbnail
                });
            },
            setProject = (project, idx) => {
                featuredProjects()[idx] = _.first(project);
                uservm.id(_.first(project).user.id);
                lUser().load().then(user => setUser(user, idx));
            },
            projectCategory = prop('-1'),
            projectName = prop(''),
            projectNameError = prop(false),
            projectCategoryError = prop(false),
            validateProjectForm = () => {
                projectCategoryError(projectCategory() == -1);
                projectNameError(projectName().trim() === '');

                return (!projectCategoryError() && !projectNameError());
            };

        statsLoader.load().then(stats);
        loadCategories();

        vnode.state = {
            stats,
            categories,
            paneImages,
            selectCategory,
            selectedCategory,
            selectedCategoryIdx,
            selectPane,
            selectedPane,
            featuredProjects,
            linkToExternal,
            testimonials: startvm.testimonials,
            questions: startvm.questions,
            projectCategory,
            projectName,
            projectNameError,
            projectCategoryError,
            validateProjectForm
        };
    },
    view: function({state, attrs}) {
        const stats = _.first(state.stats());
        const testimonials = () => _.map(state.testimonials, (testimonial) => {
            const content = m('.card.u-radius.card-big.card-terciary', [
                m('.u-text-center.u-marginbottom-20', [
                    m(`img.thumb-testimonial.u-round.u-marginbottom-20[src="${testimonial.thumbUrl}"]`)
                ]),
                m('p.fontsize-large.u-marginbottom-30', `"${testimonial.content}"`),
                m('.u-text-center', [
                    m('.fontsize-large.fontweight-semibold', testimonial.name),
                    m('.fontsize-base', testimonial.totals)
                ])
            ]);

            return {
                content
            };
        });

        return m('#start', { oncreate: h.setPageTitle(window.I18n.t('header_html', I18nScope())) }, [
            m('.w-section.hero-full.hero-start', [
                m('.w-container.u-text-center', [
                    m('.fontsize-megajumbo.fontweight-semibold.u-marginbottom-40', window.I18n.t('slogan', I18nScope())),
                    m('.w-row.u-marginbottom-40', [
                        m('.w-col.w-col-4.w-col-push-4', [
                            m('a.btn.btn-large.u-marginbottom-10[href="#start-form"]', {
                                oncreate: h.scrollTo(),
                                onclick: h.analytics.event({ cat: 'project_start', act: 'start_btnstart_click' })
                            }, window.I18n.t('submit', I18nScope()))
                        ])
                    ]),
                    m('.w-row', _.isEmpty(stats) ? '' : [
                        m('.w-col.w-col-4', [
                            m('.fontsize-largest.lineheight-loose', h.formatNumber(stats.total_contributors, 0, 3)),
                            m('p.fontsize-small.start-stats', window.I18n.t('header.people', I18nScope()))
                        ]),
                        m('.w-col.w-col-4', [
                            m('.fontsize-largest.lineheight-loose', `${stats.total_contributed.toString().slice(0, 2)} milhões`),
                            m('p.fontsize-small.start-stats', window.I18n.t('header.money', I18nScope()))
                        ]),
                        m('.w-col.w-col-4', [
                            m('.fontsize-largest.lineheight-loose', h.formatNumber(stats.total_projects_success, 0, 3)),
                            m('p.fontsize-small.start-stats', window.I18n.t('header.success', I18nScope()))
                        ])
                    ])
                ])
            ]),
            m('.w-section.section', [
                m('.w-container', [
                    m('.w-row', [
                        m('.w-col.w-col-10.w-col-push-1.u-text-center', [
                            m('.fontsize-larger.u-marginbottom-10.fontweight-semibold', window.I18n.t('page-title', I18nScope())),
                            m('.fontsize-small', window.I18n.t('page-subtitle', I18nScope()))
                        ]),
                    ]),
                    m('.w-clearfix.how-row', [
                        m('.w-hidden-small.w-hidden-tiny.how-col-01', [
                            m('.info-howworks-backers', [
                                m('.fontweight-semibold.fontsize-large', window.I18n.t('banner.1', I18nScope())),
                                m('.fontsize-base', window.I18n.t('banner.2', I18nScope()))
                            ]),
                            m('.info-howworks-backers', [
                                m('.fontweight-semibold.fontsize-large', window.I18n.t('banner.3', I18nScope())),
                                m('.fontsize-base', window.I18n.t('banner.4', I18nScope()))
                            ])
                        ]),
                        m('.how-col-02'),
                        m('.how-col-03', [
                            m('.fontweight-semibold.fontsize-large', window.I18n.t('banner.5', I18nScope())),
                            m('.fontsize-base', window.I18n.t('banner.6', I18nScope())),
                            m('.fontweight-semibold.fontsize-large.u-margintop-30', window.I18n.t('banner.7', I18nScope())),
                            m('.fontsize-base', window.I18n.t('banner.8', I18nScope()))
                        ]),
                        m('.w-hidden-main.w-hidden-medium.how-col-01', [
                            m('.info-howworks-backers', [
                                m('.fontweight-semibold.fontsize-large', window.I18n.t('banner.1', I18nScope())),
                                m('.fontsize-base', window.I18n.t('banner.2', I18nScope()))
                            ]),
                            m('.info-howworks-backers', [
                                m('.fontweight-semibold.fontsize-large', window.I18n.t('banner.3', I18nScope())),
                                m('.fontsize-base', window.I18n.t('banner.4', I18nScope()))
                            ])
                        ])
                    ])
                ])
            ]),
            m('.w-section.divider'),
            m('.w-section.section-large', [
                m('.w-container.u-text-center.u-marginbottom-60', [
                    m('div', [
                        m('span.fontsize-largest.fontweight-semibold', window.I18n.t('features.title', I18nScope()))
                    ]),
                    m('.w-hidden-small.w-hidden-tiny.fontsize-large.u-marginbottom-20', window.I18n.t('features.subtitle', I18nScope())),
                    m('.w-hidden-main.w-hidden-medium.u-margintop-30', [
                        m('.fontsize-large.u-marginbottom-30', window.I18n.t('features.feature_1', I18nScope())),
                        m('.fontsize-large.u-marginbottom-30', window.I18n.t('features.feature_2', I18nScope())),
                        m('.fontsize-large.u-marginbottom-30', window.I18n.t('features.feature_3', I18nScope())),
                        m('.fontsize-large.u-marginbottom-30', window.I18n.t('features.feature_4', I18nScope())),
                        m('.fontsize-large.u-marginbottom-30', window.I18n.t('features.feature_5', I18nScope())),
                        m('.fontsize-large.u-marginbottom-30', window.I18n.t('features.feature_6', I18nScope()))
                    ])
                ]),
                m('.w-container', [
                    m('.w-tabs.w-hidden-small.w-hidden-tiny', [
                        m('.w-tab-menu.w-col.w-col-4', _.map(state.paneImages, (pane, idx) => m(`btn.w-tab-link.w-inline-block.tab-list-item${(idx === state.selectedPane()) ? '.selected' : ''}`, {
                            onclick: h.analytics.event({ cat: 'project_start', act: 'start_solution_click', lbl: pane.label }, state.selectPane(idx))
                        }, pane.label))),
                        m('.w-tab-content.w-col.w-col-8', _.map(state.paneImages, (pane, idx) => m('.w-tab-pane', [
                            m(`img[src="${pane.src}"].pane-image${(idx === state.selectedPane()) ? '.selected' : ''}`)
                        ])))
                    ])
                ])
            ]),

            m('.w-section.section-large.card-terciary',
                m('.w-container',
                    [
                        m('.u-text-center.u-marginbottom-40',
                            [
                                m('div',
                                    m('span.fontsize-largest.fontweight-semibold',
                                        window.I18n.t('mode.title', I18nScope())
                                    )
                                ),
                                m('.w-row',
                                    [
                                        m('.w-col.w-col-1'),
                                        m('.w-col.w-col-10',
                                            m('.fontsize-large.u-marginbottom-20',
                                                window.I18n.t('mode.subtitle', I18nScope())
                                            )
                                        ),
                                        m('.w-col.w-col-1')
                                    ]
                                )
                            ]
                        ),
                        m('div',
                            m('.flex-row.u-marginbottom-40',
                                [
                                    m('.flex-column.card.u-radius.u-marginbottom-30',
                                        [
                                            m('.u-text-center.u-marginbottom-30',
                                                m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/57ba58b4846cc19e60acdd5b/5a4e2fd4056b6a0001013595_aon-badge.png\']')
                                            ),
                                            m('.fontsize-large.flex-column.u-marginbottom-20',
                                                [
                                                    window.I18n.t('mode.aon.info', I18nScope()),
                                                    m.trust('&nbsp;')
                                                ]
                                            ),
                                            m('.fontsize-base.flex-column.fontcolor-secondary',
                                                window.I18n.t('mode.aon.info_2', I18nScope())
                                            )
                                        ]
                                    ),
                                    m('.flex-column.card.u-radius.u-marginbottom-30',
                                        [
                                            m('.u-text-center.u-marginbottom-30',
                                                m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/57ba58b4846cc19e60acdd5b/5a4e2fd48aff0400011446b8_flex-badge.png\']')
                                            ),
                                            m('.fontsize-large.flex-column.u-marginbottom-20',
                                                window.I18n.t('mode.flex.info', I18nScope())
                                            ),
                                            m('.fontsize-base.flex-column.fontcolor-secondary',
                                                window.I18n.t('mode.flex.info_2', I18nScope())
                                            )
                                        ]
                                    ),
                                    m('.flex-column.card.u-radius.u-marginbottom-30.card-secondary',
                                        [
                                            m('.u-text-center.u-marginbottom-30',
                                                m('img[src=\'https://daks2k3a4ib2z.cloudfront.net/57ba58b4846cc19e60acdd5b/5a4e2fd4872fe200012f7fed_ass-badge.png\']')
                                            ),
                                            m('.fontsize-large.flex-column.u-marginbottom-20',
                                                window.I18n.t('mode.sub.info', I18nScope())
                                            ),
                                            m('.fontsize-base.flex-column.fontcolor-secondary',
                                                [
                                                    window.I18n.t('mode.sub.info_2', I18nScope()),
                                                    m.trust(window.I18n.t('mode.sub.more_link', I18nScope()))
                                                ]
                                            )
                                        ]
                                    )
                                ]
                            )
                        ),
                        m('.u-text-center.u-marginbottom-30',
                            [
                                m('.fontsize-large.fontweight-semibold',
                                    window.I18n.t('mode.tax_info', I18nScope())
                                ),
                                m('.fontsize-smallest.fontcolor-secondary',
                                    [
                                        window.I18n.t('mode.failed_info', I18nScope()),
                                        m.trust(window.I18n.t('mode.more_link', I18nScope()))
                                    ]
                                )
                            ]
                        )
                    ]
                )
            ),

            m('.w-section.section-large.bg-blue-one', [
                m('.w-container.u-text-center', [
                    m('.fontsize-larger.lineheight-tight.fontcolor-negative.u-marginbottom-20', [
                        window.I18n.t('video.title', I18nScope()),
                        m('br'),
                        window.I18n.t('video.subtitle', I18nScope())
                    ]),
                    m(youtubeLightbox, {
                        src: window.I18n.t('video.src', I18nScope()),
                        onclick: h.analytics.event({ cat: 'project_start', act: 'start_video_play' })
                    })
                ])
            ]),
            m('.w-hidden-small.w-hidden-tiny.section-categories', [
                m('.w-container', [
                    m('.u-text-center', [
                        m('.w-row', [
                            m('.w-col.w-col-10.w-col-push-1', [
                                m('.fontsize-large.u-marginbottom-40.fontcolor-negative', window.I18n.t('categories.title', I18nScope()))
                            ])
                        ])
                    ]),
                    m('.w-tabs', [
                        m('.w-tab-menu.u-text-center', _.map(state.categories(), category => m(`a.w-tab-link.w-inline-block.btn-category.small.btn-inline${(state.selectedCategoryIdx() === category.id) ? '.w--current' : ''}`, {
                            onclick: h.analytics.event({ cat: 'project_start', act: 'start_category_click', lbl: category.name }, state.selectCategory(category))
                        }, [
                            m('div', category.name)
                        ]))),
                        m('.w-tab-content.u-margintop-40', [
                            m('.w-tab-pane.w--tab-active', [
                                m('.w-row', (state.selectedCategoryIdx() !== -1) ? _.map(state.selectedCategory(), category => [
                                    m('.w-col.w-col-5', [
                                        m('.fontsize-jumbo.u-marginbottom-20', category.name),
                                        m('a.w-button.btn.btn-medium.btn-inline.btn-dark[href="#start-form"]', {
                                            oncreate: h.scrollTo()
                                        }, window.I18n.t('submit', I18nScope()))
                                    ]),
                                    m('.w-col.w-col-7', [
                                        m('.fontsize-megajumbo.fontcolor-negative', `R$ ${category.total_successful_value ? h.formatNumber(category.total_successful_value, 2, 3) : '...'}`),
                                        m('.fontsize-large.u-marginbottom-20', 'Doados para projetos'),
                                        m('.fontsize-megajumbo.fontcolor-negative', (category.successful_projects) ? category.successful_projects : '...'),
                                        m('.fontsize-large.u-marginbottom-30', 'Projetos financiados'),
                                        !_.isEmpty(state.featuredProjects()) ? _.map(state.featuredProjects(), project => !_.isUndefined(project) ? m('.w-row.u-marginbottom-10', [
                                            m('.w-col.w-col-1', [
                                                m(`img.user-avatar[src="${h.useAvatarOrDefault(project.userThumb)}"]`)
                                            ]),
                                            m('.w-col.w-col-11', [
                                                m('.fontsize-base.fontweight-semibold', project.user.public_name || project.user.name),
                                                m('.fontsize-smallest', [
                                                    window.I18n.t('categories.pledged', I18nScope({ pledged: h.formatNumber(project.pledged), contributors: project.total_contributors })),
                                                    m(`a.link-hidden[href="/${project.permalink}"]`, project.name)
                                                ])
                                            ])
                                        ]) : m('.fontsize-base', window.I18n.t('categories.loading_featured', I18nScope()))) : '',
                                    ])
                                ]) : '')
                            ])
                        ])
                    ])
                ])
            ]),
            m(slider, {
                slides: testimonials(),
                title: window.I18n.t('testimonials_title', I18nScope()),
                slideClass: 'slide-testimonials-content',
                wrapperClass: 'slide-testimonials',
                onchange: h.analytics.event({ cat: 'project_start', act: 'start_testimonials_change' })
            }),
            m('.w-section.divider.u-margintop-30'),
            m('.w-container', [
                m('.fontsize-larger.u-text-center.u-marginbottom-60.u-margintop-40', window.I18n.t('qa_title', I18nScope())),
                m('.w-row.u-marginbottom-60', [
                    m('.w-col.w-col-6', _.map(state.questions.col_1, question => m(landingQA, {
                        question: question.question,
                        answer: question.answer,
                        onclick: h.analytics.event({ cat: 'project_start', act: 'start_qa_click', lbl: question.question })
                    }))),
                    m('.w-col.w-col-6', _.map(state.questions.col_2, question => m(landingQA, {
                        question: question.question,
                        answer: question.answer,
                        onclick: h.analytics.event({ cat: 'project_start', act: 'start_qa_click', lbl: question.question })
                    })))
                ])
            ]),
            m('#start-form.w-section.section-large.u-text-center.bg-purple.before-footer', [
                m('.w-container', [
                    m('.fontsize-jumbo.fontcolor-negative.u-marginbottom-60', 'Crie o seu rascunho gratuitamente!'),
                    m('form[action="/projects/fallback_create"][method="GET"].w-row.w-form', {
                        onsubmit: (e) => {
                            h.analytics.oneTimeEvent({ cat: 'project_create', act: 'create_form_submit' })(e);
                            return state.validateProjectForm();
                        }
                    },
                        [
                            m('.w-col.w-col-2'),
                            m('.w-col.w-col-8', [
                                m('.fontsize-larger.fontcolor-negative.u-marginbottom-10', window.I18n.t('form.title', I18nScope())),
                                m('input[name="utf8"][type="hidden"][value="✓"]'),
                                m(`input[name="authenticity_token"][type="hidden"][value="${h.authenticityToken()}"]`),
                                m('input.w-input.text-field.medium.u-marginbottom-30[type="text"]', {
                                    name: 'project[name]',
                                    class: state.projectNameError() ? 'error' : '',
                                    onfocus: () => state.projectNameError(false),
                                    onchange: (e) => {
                                        h.analytics.oneTimeEvent({ cat: 'project_create', act: 'create_form_change', lbl: 'name' })(e);
                                        m.withAttr('value', state.projectName)(e);
                                    }
                                }),
                                m('.fontsize-larger.fontcolor-negative.u-marginbottom-10', 'na categoria'),
                                m('select.w-select.text-field.medium.u-marginbottom-40', {
                                    name: 'project[category_id]',
                                    class: state.projectCategoryError() ? 'error' : '',
                                    onfocus: () => state.projectCategoryError(false),
                                    onchange: (e) => {
                                        h.analytics.oneTimeEvent({ cat: 'project_create', act: 'create_form_change', lbl: 'category' })(e);
                                        m.withAttr('value', state.projectCategory)(e);
                                    }
                                }, [
                                    m('option[value="-1"]', window.I18n.t('form.select_default', I18nScope())),
                                    _.map(state.categories(), category => m('option', { value: category.id, selected: state.projectCategory() === category.id }, category.name))
                                ])
                            ]),
                            m('.w-col.w-col-2'),
                            m('.w-row.u-marginbottom-20', [
                                m('.w-col.w-col-4.w-col-push-4.u-margintop-40', [
                                    m(`input[type="submit"][value="${window.I18n.t('form.submit', I18nScope())}"].w-button.btn.btn-large`)
                                ]),
                            ]),
                            m('.w-row.u-marginbottom-80', (state.projectNameError() || state.projectCategoryError()) ? m(
                                inlineError,
                                { message: 'Por favor, verifique novamente os campos acima!' }
                            ) : '')
                        ])
                ])
            ])
        ]);
    }
};

export default start;
