/**
 * window.c.ProjectDashboardMenu component
 * build dashboard project menu for project owners
 * and admin.
 *
 * Example:
 * m.component(c.ProjectDashboardMenu, {
 *     project: projectDetail Object,
 * })
 */
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import railsErrorsVM from '../vms/rails-errors-vm';
import projectVM from '../vms/project-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.dashboard_nav');
const linksScope = _.partial(h.i18nScope, 'projects.dashboard_nav_links');

const projectDashboardMenu = {
    oninit: function(vnode) {
        const body = document.getElementsByTagName('body')[0],
            editLinksToggle = h.toggleProp(true, false),
            validating = prop(false),
            showPublish = h.toggleProp(true, false),
            bodyToggleForNav = h.toggleProp('body-project open', 'body-project closed'),
            validatePublish = () => {
                validating(true);
                m.redraw();
                m.request({
                    method: 'GET',
                    url: `/projects/${vnode.attrs.project().project_id}/validate_publish`,
                    config: h.setCsrfToken
                }).then(() => {
                    validating(false);
                    window.location.href = (`/projects/${vnode.attrs.project().project_id}/publish`);
                    m.redraw();
                }).catch((err) => {
                    validating(false);
                    railsErrorsVM.setRailsErrors(err.errors_json);
                    m.redraw();
                });
            },
            projectThumb = (project) => {
                if (_.isEmpty(project.large_image)) {
                    if (_.isEmpty(project.thumb_image)) {
                        return '/assets/thumb-project.png';
                    }
                    return project.thumb_image;
                }
                return project.large_image;
            };

        if (vnode.attrs.project().is_published) {
            editLinksToggle.toggle(false);
        }

        if (vnode.attrs.hidePublish) {
            showPublish.toggle(false);
        }

        vnode.state = {
            body,
            validating,
            validatePublish,
            editLinksToggle,
            showPublish,
            bodyToggleForNav,
            projectThumb
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project(),
            projectRoute = `/projects/${project.project_id}`,
            editRoute = `${projectRoute}/edit`,
            editLinkClass = hash => `dashboard-nav-link-left ${project.is_published ? 'indent' : ''} ${h.hashMatch(hash) ? 'selected' : ''}`;
        const optionalOpt = m('span.fontsize-smallest.fontcolor-secondary', ' (opcional)');

        state.body.className = state.bodyToggleForNav();
        return m('#project-nav', [
            m('.project-nav-wrapper', [
                m('nav.w-section.dashboard-nav.side', [
                    m(`a#dashboard_preview_link.w-inline-block.dashboard-project-name[href="${project.is_published ? `/${project.permalink}` : `${editRoute}#preview`}"]`, {
                        onclick: projectVM.routeToProject(project, attrs.ref)
                    }, [
                        m(`img.thumb-project-dashboard[src="${project ? state.projectThumb(project) : '/assets/thumb-project.png'}"][width="114"]`),
                        m('.fontcolor-negative.lineheight-tight.fontsize-small', project.name),
                        m(`img.u-margintop-10[src="/assets/catarse_bootstrap/badge-${project.mode}-h.png"]`, {
                            width: projectVM.isSubscription(project) ? 130 : 80
                        })
                    ]),
                    m('#info-links.u-marginbottom-20', [
                        (project.state === 'draft' && projectVM.isSubscription(project)) ?
                        m(`a#dashboard_home_link[class="${editLinkClass('#start')}"][href="${editRoute}#start"]`, [
                            m('span.fa.fa-info.fa-lg.fa-fw'), window.I18n.t('draft_start_tab', I18nScope())
                        ]) :
                        m(`a#dashboard_home_link[class="dashboard-nav-link-left ${h.locationActionMatch('insights') ? 'selected' : ''}"][href="${projectRoute}/insights"]`, {
                            oncreate: m.route.link
                        }, [
                            m('span.fa.fa-bar-chart.fa-lg.fa-fw'), window.I18n.t('start_tab', I18nScope())
                        ]), (project.is_published ? [
                            projectVM.isSubscription(project) ?
                            m(`a#dashboard_subscriptions_link[class="dashboard-nav-link-left ${h.locationActionMatch('subscriptions_report') ? 'selected' : ''}"][href="${projectRoute}/subscriptions_report"]`, {
                                oncreate: m.route.link
                            }, [
                                m('span.fa.fa.fa-users.fa-lg.fa-fw'), window.I18n.t('subscriptions_tab', I18nScope())
                            ]) :
                            m(`a#dashboard_reports_link[class="dashboard-nav-link-left ${h.locationActionMatch('contributions_report') ? 'selected' : ''}"][href="${projectRoute}/contributions_report"]`, {
                                oncreate: m.route.link
                            }, [
                                m('span.fa.fa.fa-table.fa-lg.fa-fw'), window.I18n.t('reports_tab', I18nScope())
                            ]),
                            m(`a#dashboard_posts_link[class="dashboard-nav-link-left ${h.locationActionMatch('posts') ? 'selected' : ''}"][href="${projectRoute}/posts"]`, [
                                m('span.fa.fa-bullhorn.fa-fw.fa-lg'),
                                window.I18n.t('posts_tab', I18nScope()),
                                project.posts_count > 0 ?
                                m('span.badge', project.posts_count) :
                                m('span.badge.badge-attention', '0')
                            ]),

                            (projectVM.isSubscription(project) ? '' :
                                m(`a#dashboard_surveys_link[class="dashboard-nav-link-left ${h.locationActionMatch('surveys') ? 'selected' : ''}"][href="${projectRoute}/surveys"]`, {
                                    oncreate: m.route.link
                                }, [
                                    m('span.fa.fa.fa-check-square-o.fa-lg.fa-fw'), window.I18n.t('surveys_tab', I18nScope())
                                ])),

                            m(`a#dashboard_fiscal_link[class="dashboard-nav-link-left ${h.locationActionMatch('fiscal') ? 'selected' : ''}"][href="${projectRoute}/fiscal"]`, {
                                oncreate: m.route.link
                            }, [
                                m('span.fa.fa.fa-book.fa-lg.fa-fw'), window.I18n.t('fiscal_tab', I18nScope())
                            ])

                        ] : '')
                    ]),
                    m('.edit-project-div', [
                        (!project.is_published ? '' : m('button#toggle-edit-menu.dashboard-nav-link-left', {
                            onclick: state.editLinksToggle.toggle
                        }, [
                            m('span.fa.fa-pencil.fa-fw.fa-lg'), window.I18n.t('edit_project', I18nScope())
                        ])), (state.editLinksToggle() ? m('#edit-menu-items', [
                            m('#dashboard-links', [
                                ((!project.is_published || project.is_admin_role) ? [
                                    m(`a#basics_link[class="${editLinkClass('#basics')}"][href="${editRoute}#basics"]`, railsErrorsVM.errorsFor('basics'), window.I18n.t('basics_tab', linksScope())),
                                    projectVM.isSubscription(project) ? '' : m(`a#goal_link[class="${editLinkClass('#goal')}"][href="${editRoute}#goal"]`, railsErrorsVM.errorsFor('goal'), window.I18n.t('goal_tab', linksScope())),
                                ] : ''),
                                projectVM.isSubscription(project) ? m(`a#goals_link[class="${editLinkClass('#goals')}"][href="${editRoute}#goals"]`, railsErrorsVM.errorsFor('goals'), window.I18n.t('goals_tab', linksScope())) : '',
                                m(`a#description_link[class="${editLinkClass('#description')}"][href="${editRoute}#description"]`, railsErrorsVM.errorsFor('description'), window.I18n.t('description_tab', linksScope())),
                                projectVM.isSubscription(project) ? null : m(`a#video_link[class="${editLinkClass('#video')}"][href="${editRoute}#video"]`, [railsErrorsVM.errorsFor('video'),
                                    'Vídeo', m('span.fontsize-smallest.fontcolor-secondary', ' (opcional)')
                                ]),
                                projectVM.isSubscription(project) ? null :
                                m(`a#budget_link[class="${editLinkClass('#budget')}"][href="${editRoute}#budget"]`, railsErrorsVM.errorsFor('budget'), window.I18n.t('budget_tab', linksScope())),
                                m(`a#card_link[class="${editLinkClass('#card')}"][href="${editRoute}#card"]`, railsErrorsVM.errorsFor('card'), window.I18n.t(`card_tab_${project.mode}`, linksScope())),
                                m(`a#dashboard_reward_link[class="${editLinkClass('#reward')}"][href="${editRoute}#reward"]`, [railsErrorsVM.errorsFor('reward'),
                                    'Recompensas', optionalOpt
                                ]),
                                m(`a#integrations[class="${editLinkClass('#integrations')}"][href="${editRoute}#integrations"]`, [railsErrorsVM.errorsFor('integrations'),
                                    'Integrações', optionalOpt
                                ]),
                                projectVM.isSubscription(project) ?
                                m(`a#dashboard_welcome_message_link[class="${editLinkClass('#welcome_message')}"][href="${editRoute}#welcome_message"]`, [railsErrorsVM.errorsFor('welcome_message'),
                                    'Email de boas vindas', optionalOpt
                                ]) : null,
                                m(`a#dashboard_user_about_link[class="${editLinkClass('#user_about')}"][href="${editRoute}#user_about"]`, railsErrorsVM.errorsFor('user_about'), window.I18n.t('about_you_tab', linksScope())),
                                ((project.is_published || project.state === 'draft') || project.is_admin_role ? [
                                    m(`a#dashboard_user_settings_link[class="${editLinkClass('#user_settings')}"][href="${editRoute}#user_settings"]`, railsErrorsVM.errorsFor('user_settings'), window.I18n.t('account_tab', linksScope())),
                                ] : ''), (!project.is_published ? [
                                    m(`a#dashboard_preview_link[class="${editLinkClass('#preview')}"][href="${editRoute}#preview"]`, [
                                        m('span.fa.fa-fw.fa-eye.fa-lg'), window.I18n.t('preview_tab', linksScope())
                                    ]),
                                ] : '')
                            ])
                        ]) : ''),
                        ((!project.is_published && state.showPublish()) ? [
                            (state.validating() ? h.loader() :
                                m('.btn-send-draft-fixed',
                                    (project.mode === 'aon' ? [
                                        (project.state === 'draft' ? m('button.btn.btn-medium', {
                                            onclick: state.validatePublish
                                        }, [
                                            window.I18n.t('publish', I18nScope()), m.trust('&nbsp;&nbsp;'), m('span.fa.fa-chevron-right')
                                        ]) : '')
                                    ] : [
                                        (project.state === 'draft' ? m('button.btn.btn-medium', {
                                            onclick: state.validatePublish
                                        }, [
                                            window.I18n.t('publish', I18nScope()), m.trust('&nbsp;&nbsp;'), m('span.fa.fa-chevron-right')
                                        ]) : '')
                                    ]))
                            )
                        ] : [
                            ((project.mode === 'flex' && project.is_published) ? [
                                m('.btn-send-draft-fixed',
                                    (_.isNull(project.expires_at) ? m(`a.w-button.btn.btn-medium.btn-secondary-dark[href="${editRoute}#announce_expiration"]`, window.I18n.t('announce_expiration', I18nScope())) : ''))
                            ] : '')
                        ])
                    ]),
                ]),
            ]),
            m('a.btn-dashboard href="javascript:void(0);"', {
                onclick: state.bodyToggleForNav.toggle
            }, [
                m('span.fa.fa-bars.fa-lg')
            ])
        ]);
    }
};

export default projectDashboardMenu;
