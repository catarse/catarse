import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectMode from './project-mode';
import projectReminder from './project-reminder';
import projectUserCard from './project-user-card';
import projectShareBox from './project-share-box';
import projectFriends from './project-friends';
import addressTag from './address-tag';
import categoryTag from './category-tag';
import projectVM from '../vms/project-vm';
import { ProjectWeLovedTag } from './project-we-loved-tag';

const I18nScope = _.partial(h.i18nScope, 'projects.project_sidebar');

const projectSidebar = {
    oninit: function(vnode) {
        const project = vnode.attrs.project,
            animateProgress = localVnode => {
                let animation,
                    progress = 0,
                    pledged = 0,
                    contributors = 0;
                const pledgedIncrement = project().pledged / project().progress,
                    contributorsIncrement = project().total_contributors / project().progress;

                const progressBar = document.getElementById('progressBar'),
                    pledgedEl = document.getElementById('pledged'),
                    contributorsEl = document.getElementById('contributors'),
                    incrementProgress = () => {
                        if (progress <= parseInt(project().progress)) {
                            progressBar.style.width = `${progress}%`;
                            pledgedEl.innerText = `R$ ${h.formatNumber(pledged)}`;
                            contributorsEl.innerText = `${parseInt(contributors)} pessoas`;
                            localVnode.dom.innerText = `${progress}%`;
                            pledged += pledgedIncrement;
                            contributors += contributorsIncrement;
                            progress += 1;
                        } else {
                            clearInterval(animation);
                        }
                    },
                    animate = () => {
                        animation = setInterval(incrementProgress, 28);
                    };

                setTimeout(() => {
                    animate();
                }, 1800);
            };

        const navigate = () => {
            if (projectVM.isSubscription(vnode.attrs.project)) {
                h.navigateTo(`/projects/${project().project_id}/subscriptions/start`);
                return false;
            }
            h.navigateTo(`/projects/${project().project_id}/contributions/new`);
            return false;
        };

        vnode.state = {
            animateProgress,
            displayShareBox: h.toggleProp(false, true),
            navigate
        };
    },
    view: function({state, attrs}) {
        // @TODO: remove all those things from the view
        const project = attrs.project,
            elapsed = project().elapsed_time,
            remaining = project().remaining_time,
            displayCardClass = () => {
                const states = {
                    waiting_funds: 'card-waiting',
                    successful: 'card-success',
                    failed: 'card-error',
                    draft: 'card-dark',
                    in_analysis: 'card-dark',
                    approved: 'card-dark'
                };

                return (states[project().state] ? `card u-radius zindex-10 ${states[project().state]}` : '');
            },
            displayStatusText = () => {
                const states = {
                    approved: window.I18n.t('display_status.approved', I18nScope()),
                    online: h.existy(project().zone_expires_at) && project().open_for_contributions ? window.I18n.t('display_status.online', I18nScope({ date: h.momentify(project().zone_expires_at) })) : '',
                    failed: window.I18n.t('display_status.failed', I18nScope({ date: h.momentify(project().zone_expires_at), goal: `R$ ${h.formatNumber(project().goal, 2, 3)}` })),
                    rejected: window.I18n.t('display_status.rejected', I18nScope()),
                    in_analysis: window.I18n.t('display_status.in_analysis', I18nScope()),
                    successful: window.I18n.t('display_status.successful', I18nScope({ date: h.momentify(project().zone_expires_at) })),
                    waiting_funds: window.I18n.t('display_status.waiting_funds', I18nScope()),
                    draft: window.I18n.t('display_status.draft', I18nScope())
                };

                return states[project().state];
            },
            isSub = projectVM.isSubscription(project),
            subscriptionData = attrs.subscriptionData && attrs.subscriptionData() ? attrs.subscriptionData() : prop(),
            subGoal = isSub ? (_.find(attrs.goalDetails(), g => g.value > subscriptionData.amount_paid_for_valid_period) || _.last(attrs.goalDetails()) || { value: '--' }) : null,
            pledged = isSub ? subscriptionData.amount_paid_for_valid_period : project().pledged,
            progress = isSub ? (subscriptionData.amount_paid_for_valid_period / subGoal.value) * 100 : project().progress,
            totalContributors = isSub ? subscriptionData.total_subscriptions : project().total_contributors;

        return m('#project-sidebar.aside', [
            m('.project-stats', [
                m(`.project-stats-inner${isSub ? '.dark' : ''}`, [
                    m('.project-stats-info', [
                        m('.u-marginbottom-20', [
                            m(`#pledged.${isSub ? 'fontsize-larger' : 'fontsize-largest'}.fontweight-semibold.u-text-center-small-only`, [
                                `R$ ${pledged ? h.formatNumber(pledged) : '0'}`,
                                isSub ? m('span.fontsize-large', ' por mês') : null
                            ]),
                            isSub ? m('.fontsize-small.u-text-center-small-only', [
                                window.I18n.t('subscribers_call', I18nScope()),
                                m('span#contributors.fontweight-semibold', window.I18n.t('contributors_count', I18nScope({ count: totalContributors }))),
                            ])
                                : m('.fontsize-small.u-text-center-small-only', [
                                    window.I18n.t('contributors_call', I18nScope()),
                                    m('span#contributors.fontweight-semibold', window.I18n.t('contributors_count', I18nScope({ count: totalContributors }))),
                                    (!project().expires_at && elapsed) ? ` em ${window.I18n.t(`datetime.distance_in_words.x_${elapsed.unit}`, { count: elapsed.total }, I18nScope())}` : ''
                                ])
                        ]),
                        m('.meter', [
                            m('#progressBar.meter-fill', {
                                style: {
                                    width: `${progress}%`
                                }
                            })
                        ]),
                        isSub
                            ? m('.fontsize-smaller.fontweight-semibold.u-margintop-10', `${progress ? parseInt(progress) : '0'}% de R$${subGoal.value} por mês`)
                            : m('.w-row.u-margintop-10', [
                                m('.w-col.w-col-5.w-col-small-6.w-col-tiny-6', [
                                    m('.fontsize-small.fontweight-semibold.lineheight-tighter', `${progress ? parseInt(progress) : '0'}%`)
                                ]),
                                m('.w-col.w-col-7.w-col-small-6.w-col-tiny-6.w-clearfix', [
                                    m('.u-right.fontsize-small.lineheight-tighter', remaining && remaining.total ? [
                                        m('span.fontweight-semibold', remaining.total), window.I18n.t(`remaining_time.${remaining.unit}`, I18nScope({ count: remaining.total }))
                                    ] : '')
                                ])
                            ])
                    ]),
                    m('.w-row', [
                        m(projectMode, {
                            project
                        })
                    ])
                ]),
                (project().open_for_contributions && !attrs.hasSubscription ? m('.back-project-btn-div', [
                    m('.back-project--btn-row', [
                        m('a#contribute_project_form.btn.btn-large.u-marginbottom-20[href="javascript:void(0);"]', {
                            onclick: h.analytics.event({
                                cat: 'contribution_create',
                                act: 'contribution_button_click',
                                project: project()
                            }, state.navigate)

                        }, window.I18n.t(`submit_${project().mode}`, I18nScope()))
                    ]),
                    isSub ? null : m('.back-project-btn-row-right', m(projectReminder, {
                        project,
                        type: 'link'
                    }))
                ]) : ''),
                m('.friend-backed-card.project-page', [
                    (!_.isUndefined(project()) && project().contributed_by_friends ? m(projectFriends, { project: project(), wrapper: 'div' }) : '')
                ]),
                m(`div[class="fontsize-smaller u-marginbottom-30 ${displayCardClass()}"]`, displayStatusText())
            ]),
            m('.project-share.w-hidden-main.w-hidden-medium', [
                m(addressTag, { project, isDark: isSub }),
                m(categoryTag, { project, isDark: isSub }),
                project().recommended && m(ProjectWeLovedTag, { project, isDark: isSub }),
                m('.u-marginbottom-30.u-text-center-small-only',
                    m(`button.btn.btn-inline.btn-medium.btn-terciary${projectVM.isSubscription(project) ? '.btn-terciary-negative' : ''}`, {
                        onclick: state.displayShareBox.toggle
                    }, 'Compartilhar este projeto')
                ),
                state.displayShareBox() ? m(projectShareBox, {
                    project,
                    displayShareBox: state.displayShareBox
                }) : ''
            ]),
            m('.user-c', m(projectUserCard, {
                userDetails: attrs.userDetails,
                isDark: projectVM.isSubscription(project),
                project
            }))
        ]);
    }
};

export default projectSidebar;
