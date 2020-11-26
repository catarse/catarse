import m from 'mithril';
import _ from 'underscore';
import projectRewardCard from './project-reward-card';
import projectReport from './project-report';

const projectRewardList = {
    view: function({attrs}) {
        const project = attrs.project() || {
            open_for_contributions: false
        };
        return m('#rewards', [
            m('.reward.u-marginbottom-30', _.map(_.sortBy(attrs.rewardDetails(), reward => Number(reward.row_order)), reward => m(projectRewardCard, { reward, project, hasSubscription: attrs.hasSubscription }))),
            attrs.showReport ? m(projectReport) : null
        ]);
    }
};

export default projectRewardList;
