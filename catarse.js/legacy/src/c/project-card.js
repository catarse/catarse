import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectVM from '../vms/project-vm';
import projectFriends from './project-friends';
import progressMeter from './progress-meter';
import { ComingSoonLandingPageExploreRemindButton } from '../root/projects/coming-soon-landing-page-explore-remind-button';

const I18nScope = _.partial(h.i18nScope, 'projects.card');
const projectCard = {
    oninit: function(vnode) {
        const project = vnode.attrs.project,
            progress = project.progress.toFixed(2),
            remainingTextObj = h.translatedTime(project.remaining_time),
            elapsedTextObj = h.translatedTime(project.elapsed_time),
            type = vnode.attrs.type || 'small';

        const css = () => {
            const cssClasses = {
                small: {
                    wrapper: '.w-col.w-col-4',
                    innerWrapper: '.card-project.card.u-radius',
                    thumb: '.card-project-thumb',
                    descriptionWrapper: '',
                    description: '.card-project-description.alt',
                    title: '.fontweight-semibold.u-text-center-small-only.lineheight-tight.u-marginbottom-10.fontsize-base',
                    author: '.w-hidden-small.w-hidden-tiny.fontsize-smallest.fontcolor-secondary.u-marginbottom-20',
                    headline: '.w-hidden-small.w-hidden-tiny.fontcolor-secondary.fontsize-smaller',
                    city: '.card-project-author.altt'
                },
                medium: {
                    wrapper: '.w-col.w-col-6',
                    innerWrapper: '.card-project.card.u-radius',
                    thumb: '.card-project-thumb.medium',
                    descriptionWrapper: '',
                    description: '.card-project-description.alt',
                    title: '.fontsize-large.fontweight-semibold.u-marginbottom-10',
                    author: '.w-hidden-small.w-hidden-tiny.fontsize-smallest.fontcolor-secondary.u-marginbottom-20',
                    headline: '.w-hidden-small.w-hidden-tiny.fontcolor-secondary.fontsize-smaller',
                    city: '.card-project-author.altt'
                },
                big: {
                    wrapper: '.card.u-radius.card-project',
                    innerWrapper: '.w-row',
                    thumb: '.w-col.w-col-8.w-col-medium-6.card-project-thumb.big',
                    descriptionWrapper: '.w-col.w-col-4.w-col-medium-6',
                    description: '.card-project-description.big',
                    title: '.fontsize-large.fontweight-semibold.u-marginbottom-10',
                    author: '.fontsize-smallest.fontcolor-secondary.u-marginbottom-20',
                    headline: '.fontcolor-secondary.fontsize-smaller',
                    city: '.w-hidden'
                }
            };

            return cssClasses[type];
        };

        const isFinished = project => _.contains(['successful', 'failed', 'waiting_funds'], project.state);

        const cardCopy = (project) => {
            if (projectVM.isSubscription(project)) {
                return m('img.product-label[src="https://s3.amazonaws.com/cdn.catarse/assets/assinatura-label.png"]');
            }
            if (project.expires_at) {
                return isFinished(project) ? [
                    m('.fontsize-smaller.fontweight-loose', 'Encerrado'),
                    m('.fontsize-smallest.lineheight-tightest', h.momentify(project.expires_at))
                ] : [
                    m('.fontsize-smaller.fontweight-semibold', `${remainingTextObj.total} ${remainingTextObj.unit}`),
                    m('.fontsize-smallest.lineheight-tightest', (remainingTextObj.total > 1) ? 'Restantes' : 'Restante')
                ];
            }
            return [
                m('.fontsize-smallest.lineheight-tight', ['Iniciado há', m('br'), `${elapsedTextObj.total} ${elapsedTextObj.unit}`])
            ];
        };


        vnode.state = {
            cardCopy,
            css,
            type,
            progress,
            remainingTextObj,
            elapsedTextObj,
            isFinished
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project;
        const projectOwnerName = project.user ? (project.user.public_name || project.user.name) : (project.owner_public_name || project.owner_name);

        const projectLocalizationObject = {
            filter: 'all',
            city_name: project.address ? project.address.city : project.city_name,
            state_acronym: project.address ? project.address.state_acronym : project.state_acronym,
        };
        const projectLocalizationSearchUrl = `/explore?${m.buildQueryString(projectLocalizationObject)}`
        const projectLocalizationName = project.address ? `${project.address.city}, ${project.address.state_acronym}` : `${project.city_name}, ${project.state_acronym}`;

        const projectCategoryObject = {
            filter: 'all',
            category_id: project.category_id,
        };
        const projectCategorySearchUrl = `/explore?${m.buildQueryString(projectCategoryObject)}`;
        const projectCategoryName = project.category_name;

        return m(state.css().wrapper, [
            m(state.css().innerWrapper, [
                m(`a${state.css().thumb}[href="/${project.permalink}?ref=${attrs.ref}"]`, {
                    onclick: projectVM.routeToProject(project, attrs.ref),
                    style: {
                        'background-image': `url(${project.project_img || project.large_image})`,
                        display: 'block'
                    }
                }),
                (
                    project.recommended &&
                    m('div.loved-projects-container',
                        m(`a.loved-projects-badge[href="/${window.I18n.locale}/explore?filter=projects_we_love"]`, 'Projeto que amamos')
                    )
                ),
                m(state.css().descriptionWrapper, [
                    m(state.css().description, [
                        m(state.css().title, [
                            project.is_adult_content && [ m('span.badge', '+18'), m.trust('&nbsp;') ],
                            m(`a.link-hidden[href="/${project.permalink}?ref=${attrs.ref}"]`, {
                                onclick: projectVM.routeToProject(project, attrs.ref)
                            },
                            project.project_name || project.name)
                        ]),
                        m(state.css().author, `${window.I18n.t('by', I18nScope())} ${projectOwnerName}`),
                        m(state.css().headline, [
                            m(`a.link-hidden[href="/${project.permalink}?ref=${attrs.ref}"]`, {
                                onclick: projectVM.routeToProject(project, attrs.ref)
                            }, project.headline)
                        ])
                    ]),
                        project.state === 'draft' ?
                        [
                            m(ComingSoonLandingPageExploreRemindButton, {
                                project: project,
                                isFollowing: project.in_reminder
                            })
                        ]  :
                        [
                            m(progressMeter, { progress: state.progress, project }),
                            m('.card-project-stats', [
                                m('.w-row', [
                                    m('.w-col.w-col-4.w-col-small-4.w-col-tiny-4', [
                                        m('.fontsize-base.fontweight-semibold', `${Math.floor(project.progress)}%`)
                                    ]),
                                    m('.w-col.w-col-4.w-col-small-4.w-col-tiny-4.u-text-center-small-only', [
                                        m('.fontsize-smaller.fontweight-semibold', `R$ ${h.formatNumber(project.pledged)}`),
                                        m('.fontsize-smallest.lineheight-tightest', window.I18n.t(`pledged.${project.mode}`, I18nScope()))
                                    ]),
                                    m('.w-col.w-col-4.w-col-small-4.w-col-tiny-4.u-text-right', state.cardCopy(project)),
                                ])
                            ]),
                        ],
                        m(state.css().city,
                        m('div', [
                            project.state != 'draft' ?
                            m('div',
                                m(`a.link-hidden-dark.fontsize-smallest.fontcolor-secondary[href="${projectLocalizationSearchUrl}"]`, {
                                    onclick: (/** @type {Event} */ event) => {
                                        event.preventDefault();
                                        m.route.set(projectLocalizationSearchUrl);
                                    }
                                }, [
                                    m('span.fa.fa-map-marker.fa-sm', ' '),
                                    ` ${projectLocalizationName}`
                                ])
                            ) :  m('br'),
                            m('div',
                                m(`a.link-hidden-dark.fontsize-smallest.fontcolor-secondary[href="${projectCategorySearchUrl}"]`, {
                                    onclick: (/** @type {Event} */ event) => {
                                        event.preventDefault();
                                        m.route.set(projectCategorySearchUrl);
                                    }
                                }, [
                                    m('span.fa.fa-tag.fa-sm', ' '),
                                    ` ${projectCategoryName}`
                                ])
                            )
                        ])
                    ),
                ]),
                (attrs.showFriends && state.type === 'big' ?
                 m('.w-col.w-col-4.w-col-medium-6', [m(projectFriends, { project })]) : '')
            ]),
            (attrs.showFriends && state.type !== 'big' ?
              m(projectFriends, { project }) : '')
        ]);
    }
};

export default projectCard;
