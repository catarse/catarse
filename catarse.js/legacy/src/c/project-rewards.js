import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectVM from '../vms/project-vm';
import projectRewardList from './project-reward-list';
import projectGoalsBox from './project-goals-box';

const projectRewards = {
    view: function({attrs}) {
        return m('.w-col.w-col-12', [
            projectVM.isSubscription(attrs.project) ? 
                attrs.subscriptionData() ? 
                    m(projectGoalsBox, { 
                        goalDetails: attrs.goalDetails, 
                        subscriptionData: attrs.subscriptionData 
                    })
                    :
                    h.loader()
                :
                '', 
            m(projectRewardList, _.extend({}, {
                rewardDetails: attrs.rewardDetails,
                hasSubscription: attrs.hasSubscription
            }, attrs.c_opts))
        ]);
    }
};

export default projectRewards;
