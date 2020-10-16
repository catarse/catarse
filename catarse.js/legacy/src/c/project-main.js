import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectSuggestedContributions from './project-suggested-contributions';
import projectContributions from './project-contributions';
import projectAbout from './project-about';
import projectRewards from './project-rewards';
import projectComments from './project-comments';
import projectPosts from './project-posts';
import projectVM from '../vms/project-vm';

const projectMain = {
    oninit: function(vnode) {
        const hash = prop(window.location.hash),
            displayTabContent = (project) => {
                const c_opts = {
                        project,
                        post_id: vnode.attrs.post_id,
                        subscriptionData: vnode.attrs.subscriptionData
                    },
                    tabs = {
                        '#rewards': m(projectRewards, { c_opts, project, hasSubscription: vnode.attrs.hasSubscription, goalDetails: vnode.attrs.goalDetails, subscriptionData: vnode.attrs.subscriptionData, rewardDetails: vnode.attrs.rewardDetails }),
                        '#contribution_suggestions': m(projectSuggestedContributions, c_opts),
                        '#contributions': m(projectContributions, c_opts),
                        '#about': m(projectAbout, _.extend({}, {
                            hasSubscription: vnode.attrs.hasSubscription,
                            rewardDetails: vnode.attrs.rewardDetails,
                            subscriptionData: vnode.attrs.subscriptionData,
                            goalDetails: vnode.attrs.goalDetails
                        }, c_opts)),
                        '#comments': m(projectComments, c_opts),
                        '#posts': m(projectPosts, _.extend({}, {
                            projectContributions: vnode.attrs.projectContributions,
                            userDetails: vnode.attrs.userDetails,
                        }, c_opts))
                    };

                if (_.isNumber(vnode.attrs.post_id) && !window.location.hash) {
                    window.location.hash = 'posts';
                }

                hash(window.location.hash);

                
                if (_.isEmpty(hash()) || hash() === '#_=_' || hash() === '#preview') {
                    const hasRewards = !_.isEmpty(vnode.attrs.rewardDetails());
                    const mobileDefault = hasRewards ? '#rewards' : '#contribution_suggestions';
                    return tabs[h.mobileScreen() ? mobileDefault : '#about'];
                }

                return tabs[hash()];
            };

        h.redrawHashChange();

        projectVM.checkSubscribeAction();

        vnode.state = {
            displayTabContent,
            hash
        };
    },
    view: function({state, attrs}) {
        return m('section.section[itemtype="http://schema.org/CreativeWork"]', { style: attrs.style }, [
            m(`${state.hash() !== '#contributions' ? '.w-container' : '.about-tab-content'}`, [
                m('.w-row', attrs.project() ? state.displayTabContent(attrs.project) : h.loader())
            ])
        ]);
    }
};

export default projectMain;
