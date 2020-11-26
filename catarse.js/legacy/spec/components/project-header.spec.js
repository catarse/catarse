import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import projectHeader from '../../src/c/project-header';

describe('ProjectHeader', () => {
    let $output, projectDetail, rewardDetails, goalDetails;

    describe('view', () => {
        beforeAll(() => {
            projectDetail = prop(ProjectDetailsMockery()[0]);
            rewardDetails = prop(RewardDetailsMockery());
            goalDetails = prop(GoalsMockery());
            $output = mq(m(projectHeader, {
                hasSubscription: prop(false),
                userProjectSubscriptions: prop([]),
                project: projectDetail,
                userDetails: prop([]),
                projectContributions: prop([]),
                rewardDetails: rewardDetails,
                goalDetails
            }));
        });

        it('should a project header', () => {
            expect($output.find('#project-header').length).toEqual(1);
            expect($output.contains(projectDetail().name)).toEqual(true);
        });

        it('should render project-highlight / project-sidebar component area', () => {
            expect($output.find('.project-highlight').length).toEqual(1);
            expect($output.find('#project-sidebar').length).toEqual(1);
        });
    });
});
