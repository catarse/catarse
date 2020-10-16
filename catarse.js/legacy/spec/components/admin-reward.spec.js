import mq from 'mithril-query';
import prop from 'mithril/stream';
import adminReward from '../../src/c/admin-reward';

describe('adminReward', () => {
    let ctrl, $output;

    describe('view', () => {
        let reward, ctrl;

        describe("when contribution has no reward", function() {
            beforeAll(() => {
                $output = mq(adminReward, {
                    reward: prop({}),
                    contribution: prop({})
                });
            });

            it('should render "no reward" text when reward_id is null', () => {
                $output.should.contain('Apoio sem recompensa');
            });
        });
        describe("when contribution has reward", function() {
            let reward, contribution;

            beforeAll(() => {
                reward = prop(RewardDetailsMockery()[0]);
                contribution = prop(ContributionAttrMockery()[0]);
                ctrl = adminReward.oninit({
                    attrs: {
                    reward,
                    contribution
                    }
                });
                $output = mq(adminReward, {
                    reward,
                    contribution
                });
            });

            it("should render reward description when we have a reward_id", function() {
                $output.should.contain(reward().description);
            });
        });
    });
});
