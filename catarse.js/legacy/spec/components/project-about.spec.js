import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import projectAbout from '../../src/c/project-about';

describe('ProjectAbout', () => {
    let $output, projectDetail, rewardDetail;

    describe('view', () => {
        beforeAll(() => {
            projectDetail = ProjectDetailsMockery()[0];
            rewardDetail = RewardDetailsMockery()[0];
            m.originalTrust = m.trust;
            $output = mq(projectAbout, {
                hasSubscription: prop(false),
                project: prop(projectDetail),
                rewardDetails: prop(RewardDetailsMockery()),
                goalDetails: prop(GoalsMockery())
            });
        });

        it('should render project about and reward list', () => {
            expect($output.contains(projectDetail.about_html)).toEqual(true);
            expect($output.contains(rewardDetail.description)).toEqual(true);
        });
    });
});
