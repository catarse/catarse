import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectHighlight from './project-highlight';
import projectSidebar from './project-sidebar';
import projectHeaderTitle from './project-header-title';
import userContributionDetail from './user-contribution-detail';
import userSubscriptionDetail from './user-subscription-detail';
import contributionVM from '../vms/contribution-vm';
import subscriptionVM from '../vms/subscription-vm';
import projectVM from '../vms/project-vm';

const projectHeader = {
    oninit: function(vnode) {
        const project = vnode.attrs.project,
            currentUser = h.getUser(),
            userProjectSubscriptions = vnode.attrs.userProjectSubscriptions,
            hasSubscription = vnode.attrs.hasSubscription;

        if (h.isProjectPage() && currentUser && !_.isUndefined(project())) {
            if (!projectVM.isSubscription(project)) {
                projectVM.projectContributions([]);
                contributionVM
                    .getUserProjectContributions(currentUser.user_id, project().project_id, ['paid', 'refunded', 'pending_refund'])
                    .then(projectVM.projectContributions);
            }
        }

        vnode.state = {
            hasSubscription,
            userProjectSubscriptions,
            projectContributions: projectVM.projectContributions,
            showContributions: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project,
            rewardDetails = attrs.rewardDetails,
            activeSubscriptions = _.filter(state.userProjectSubscriptions(), sub => sub.status === 'active'),
            sortedSubscriptions = _.sortBy(state.userProjectSubscriptions(), sub => _.indexOf(['active', 'started', 'canceling', 'inactive', 'canceled'], sub.status));

        const hasContribution = (
            (!_.isEmpty(state.projectContributions()) || state.hasSubscription()) ?
            m(`.card.card-terciary.u-radius.u-marginbottom-40${projectVM.isSubscription(project) ? '.fontcolor-primary' : ''}`, [
                m('.fontsize-small.u-text-center', [
                    m('span.fa.fa-thumbs-up'),
                    m('span.fontweight-semibold', (!projectVM.isSubscription(project) ? ' Você é apoiador deste projeto! ' : ' Você tem uma assinatura neste projeto! ')),
                    m('a.alt-link[href=\'javascript:void(0);\']', {
                        onclick: state.showContributions.toggle
                    }, 'Detalhes')
                ]),
                state.showContributions() ? m('.u-margintop-20.w-row',
                    (!projectVM.isSubscription(project) ?
                        _.map(state.projectContributions(), contribution => m(userContributionDetail, {
                            contribution,
                            rewardDetails
                        })) :
                     _.map(activeSubscriptions.length > 0 ? activeSubscriptions : sortedSubscriptions, subscription => m(userSubscriptionDetail, {
                         subscription,
                         project: project()
                     }))
                    )
                ) : ''
            ]) :
            '');
        const hasBackground = Boolean(project().cover_image);

        return !_.isUndefined(project()) ? m('#project-header', { style: attrs.style }, [
            m(`.w-section.section-product.${project().mode}`),
            m(`${projectVM.isSubscription(project) ? '.dark' : ''}.project-main-container`, {
                class: hasBackground ? 'project-with-background' : null,
                style: hasBackground ? `background-image: linear-gradient(180deg, rgba(0, 4, 8, .82), rgba(0, 4, 8, .82)), url("${project().cover_image}");` : null
            }, [
                m(projectHeaderTitle, {
                    project,
                    children: hasContribution
                }),
                m(`.w-section.project-main${projectVM.isSubscription(project) ? '.transparent-background' : ''}`, [
                    m('.w-container', [
                        m('.w-row', [
                            m('.w-col.w-col-8.project-highlight', m(projectHighlight, {
                                project
                            })),
                            m('.w-col.w-col-4', m(projectSidebar, {
                                project,
                                hasSubscription: state.hasSubscription(),
                                subscriptionData: attrs.subscriptionData,
                                userDetails: attrs.userDetails,
                                goalDetails: attrs.goalDetails
                            }))
                        ])
                    ])
                ])
            ])
        ]) : m('');
    }
};

export default projectHeader;
