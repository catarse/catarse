import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../../h';
import projectVM from '../../vms/project-vm';
import userVM from '../../vms/user-vm';
import projectHeader from '../../c/project-header';
import projectTabs from '../../c/project-tabs';
import projectMain from '../../c/project-main';
import subscriptionVM from '../../vms/subscription-vm';
import { AdultPopupModal } from '../../c/adult-popup-modal';
import modalBox from '../../c/modal-box';
import { getCurrentUserCached } from '../../shared/services/user/get-current-user-cached';
import { isLoggedIn } from '../../shared/services/user/is-logged-in';

const projectPage = {
    oninit: function(vnode) {
        const {
            ViewContentEvent,
        } = projectVM;

        projectVM.sendPageViewForCurrentProject(vnode.attrs.project_id, [ ViewContentEvent() ]);

        const {
            project_id,
            project_user_id,
            post_id
        } = vnode.attrs;

        const currentUser = getCurrentUserCached();
        const loading = prop(true);
        const userProjectSubscriptions = prop([]);
        const projectOwner = userVM.fetchUser(project_user_id, true, prop({}));

        const currentUserIsProjectOwner = isLoggedIn(currentUser) && currentUser && (project_user_id == currentUser.id || currentUser.is_admin_role);

        const displayAdultContentPopup = h.toggleProp(!currentUserIsProjectOwner, currentUserIsProjectOwner);

        if (project_id && !_.isNaN(Number(project_id))) {
            projectVM.init(project_id, project_user_id);
        } else {
            projectVM.getCurrentProject();
        }

        if (post_id) {
            window.location.hash = '#posts';
        }

        try {
            h.analytics.windowScroll({
                cat: 'project_view',
                act: 'project_page_scroll',
                project: project_id ? {
                    id: project_id,
                    user_id: project_user_id
                } : null
            });
            setTimeout(function(){
                h.analytics.event({
                    cat: 'project_view',
                    act: 'project_page_view',
                    project: project_id ? {
                        id: project_id,
                        user_id: project_user_id
                    } : null
                }).call();
            },1000);
        } catch (e) {
            console.error(e);
        }

        const loadUserSubscriptions = () => {
            if (h.isProjectPage() && isLoggedIn(currentUser) && loading()) {
                loading(false);
                if (projectVM.isSubscription(projectVM.currentProject())) {
                    const statuses = ['started', 'active', 'canceling', 'canceled', 'inactive'];
                    subscriptionVM
                        .getUserProjectSubscriptions(currentUser.common_id, projectVM.currentProject().common_id, statuses)
                        .then(userProjectSubscriptions)
                        .then(() => h.redraw());
                }
            }
        };

        loadUserSubscriptions();

        const hasSubscription = () => !_.isEmpty(userProjectSubscriptions()) && _.find(userProjectSubscriptions(), sub => sub.project_id === projectVM.currentProject().common_id);

        vnode.state = {
            projectOwner,
            projectVM,
            hasSubscription,
            userProjectSubscriptions,
            displayAdultContentPopup,
        };
    },
    view: function({state, attrs}) {
        const project = state.projectVM.currentProject;
        const projectVM = state.projectVM;
        const projectOwner = state.projectOwner;
        const displayAdultContentPopup = state.displayAdultContentPopup;
        const shouldDisplayAdultContentPopup = project() && project().is_adult_content && displayAdultContentPopup() && !project().is_owner_or_admin;
        const blurredScreenConditionalStyle = shouldDisplayAdultContentPopup ? { filter: 'blur(7px)' } : { };

        return m('.project-show', {
            oncreate: projectVM.setProjectPageTitle(),
        }, project() ? [

            (shouldDisplayAdultContentPopup ? m(modalBox, {
                displayModal: displayAdultContentPopup,
                content: [
                    AdultPopupModal,
                    /** @type {AdultPopupModalAttrs} */
                    {
                        userPublicName: projectOwner().public_name,
                        userPhotoUrl: userVM.displayImage(projectOwner()),
                        onAgree: displayAdultContentPopup.toggle
                    }
                ],
                hideCloseButton: true,
            }) : ''),

            m(projectHeader, {
                style: blurredScreenConditionalStyle,
                project,
                hasSubscription: state.hasSubscription,
                userProjectSubscriptions: state.userProjectSubscriptions,
                subscriptionData: projectVM.subscriptionData,
                rewardDetails: projectVM.rewardDetails,
                userDetails: projectVM.userDetails,
                projectContributions: projectVM.projectContributions,
                goalDetails: projectVM.goalDetails
            }),
            m(projectTabs, {
                style: blurredScreenConditionalStyle,
                project,
                hasSubscription: state.hasSubscription,
                subscriptionData: projectVM.subscriptionData,
                rewardDetails: projectVM.rewardDetails
            }),
            m(projectMain, {
                style: blurredScreenConditionalStyle,
                project,
                post_id: attrs.post_id,
                hasSubscription: state.hasSubscription,
                rewardDetails: projectVM.rewardDetails,
                subscriptionData: projectVM.subscriptionData,
                goalDetails: projectVM.goalDetails,
                userDetails: projectVM.userDetails,
                projectContributions: projectVM.projectContributions
            })
        ] : h.loader())
    }
};

export default projectPage;
