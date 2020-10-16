import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import userContributedBox from './user-contributed-box';

const userContributionDetail = {
    oninit: function(vnode) {
        const contribution = vnode.attrs.contribution,
            rewardDetails = vnode.attrs.rewardDetails,
            chosenReward = _.findWhere(rewardDetails(), {
                id: contribution.reward_id
            });

        vnode.state = {
            contribution,
            chosenReward
        };
    },
    view: function({state, attrs}) {
        const contribution = attrs.contribution;

        return m(userContributedBox, { contribution });
    }
};

export default userContributionDetail;
