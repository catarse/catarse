import m from 'mithril';
import _ from 'underscore';
import moment from 'moment';
import h from '../h';
import projectVM from '../vms/project-vm';
import projectRewardList from './project-reward-list';
import projectGoalsBox from './project-goals-box';
import projectReport from './project-report';
import projectSuggestedContributions from './project-suggested-contributions';

const projectAbout = {
    view: function({attrs}) {
        const project = attrs.project() || {},
            onlineDays = () => {
                const diff = moment(project.zone_online_date).diff(moment(project.zone_expires_at)),
                    duration = moment.duration(diff);

                return -Math.ceil(duration.asDays());
            };
        const fundingPeriod = () => (project.is_published && h.existy(project.zone_expires_at)) ? m('.funding-period', [
            m('.fontsize-small.fontweight-semibold.u-text-center-small-only', 'Período de campanha'),
            m('.fontsize-small.u-text-center-small-only', `${h.momentify(project.zone_online_date)} - ${h.momentify(project.zone_expires_at)} (${onlineDays()} dias)`)
        ]) : '';

        const nextStepsCardOptions = () => {
            const isSubscription = projectVM.isSubscription(project);
            const hasRewards = !_.isEmpty(attrs.rewardDetails());
            const titleText = hasRewards ? 'Recompensas' : 'Sugestões de apoio';

            return [
                isSubscription ? [
                    m('.fontsize-base.fontweight-semibold.u-marginbottom-30', titleText),
                ] : [
                    m('.fontsize-base.u-marginbottom-30.w-hidden-small.w-hidden-tiny', [
                        m('span.fontweight-semibold', titleText),
                        m.trust('&nbsp;'),
                        m('span.badge.fontsize-smaller.badge-success', 'parcele em até 6x')
                    ])
                ],
                hasRewards ? [
                    m(projectRewardList, {
                        project: attrs.project,
                        hasSubscription: attrs.hasSubscription,
                        rewardDetails: attrs.rewardDetails
                    })
                ] : [
                    m(projectSuggestedContributions, { project: attrs.project })
                ],
                fundingPeriod()
            ];
        };

        return m('#project-about', [
            m('.project-about.w-col.w-col-8', {
                oncreate: h.UIHelper()
            }, [
                m('p.fontsize-base', [
                    m('strong', 'O projeto'),
                ]),
                m('.fontsize-base[itemprop="about"]', m.originalTrust(h.selfOrEmpty(project.about_html, '...'))),
                project.budget ? [
                    m('p.fontsize-base.fontweight-semibold', 'Orçamento'),
                    m('p.fontsize-base', m.originalTrust(project.budget))
                ] : '',
                m(projectReport)
            ]),
            m('.w-col.w-col-4.w-hidden-small.w-hidden-tiny', [
                projectVM.isSubscription(project) ? (attrs.subscriptionData() ? m(projectGoalsBox, { goalDetails: attrs.goalDetails, subscriptionData: attrs.subscriptionData }) : h.loader()) : '',
                nextStepsCardOptions()
            ])
        ]);
    }
};

export default projectAbout;
