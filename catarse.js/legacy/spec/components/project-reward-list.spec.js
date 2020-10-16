import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../../src/h';
import projectRewardList from '../../src/c/project-reward-list';

describe('ProjectRewardList', () => {
    let generateContextByNewState;

    describe('view', () => {
        beforeAll(() => {
            generateContextByNewState = (newState = {}) => {
                let rewardDetail = RewardDetailsMockery(newState);

                return {
                    output: mq(projectRewardList, {
                        project: prop({
                            id: 1231,
                            open_for_contributions: true
                        }),
                        hasSubscription: prop(false),
                        rewardDetails: prop(rewardDetail)
                    }),
                    rewardDetail: rewardDetail[0]
                };
            };
        });

        it('should render card-gone when reward sould out', () => {
            let {
                output, rewardDetail
            } = generateContextByNewState({
                maximum_contributions: 4,
                paid_count: 4
            });

            expect(output.find('.card-gone').length).toEqual(1);
            expect(output.contains('Esgotada')).toEqual(true);
        });

        it('should render card-reward when reward is not sould out', () => {
            let {
                output, rewardDetail
            } = generateContextByNewState({
                maximum_contributions: null
            });

            expect(output.find('.card-reward').length).toEqual(1);
            expect(output.contains('Esgotada')).toEqual(false);
        });

        it('should render card-reward stats when reward is limited and project is opened for contributions', () => {
            let {
                output, rewardDetail
            } = generateContextByNewState({
                maximum_contributions: 10,
                paid_count: 2,
                waiting_payment_count: 5
            });

            expect(output.find('.card-reward').length).toEqual(1);
            expect(output.contains('Limitada')).toEqual(true);
            expect(output.contains('(3 de 10 disponíveis)')).toEqual(true);
            expect(output.contains('2 apoios')).toEqual(true);
            expect(output.contains('5 apoios em prazo de confirmação')).toEqual(true);
        });

        it('should render card-reward details', () => {
            let {
                output, rewardDetail
            } = generateContextByNewState({
                minimum_value: 20
            });

            expect(output.find('.card-reward').length).toEqual(1);
            expect(output.contains('R$ 20 ou mais')).toEqual(true);
            expect(output.contains('Entrega prevista:')).toEqual(true);
            expect(output.contains(h.momentify(rewardDetail.deliver_at, 'MMM/YYYY'))).toEqual(true)
            expect(output.contains(rewardDetail.description)).toEqual(true);
        });

        it('should not render a contribution input value when reward is sold out', () => {
            let {
                output, rewardDetail
            } = generateContextByNewState({
                maximum_contributions: 4,
                paid_count: 4
            });

            output.click('.card-gone');
            expect(output.find('#contribution-submit').length).toEqual(0);

        });

        it('should render an input value when card reward is clicked', () => {
            let {
                output, rewardDetail
            } = generateContextByNewState({
                minimum_value: 20
            });

            output.click('.card-reward');

            expect(output.find('#contribution-submit').length).toEqual(0);
        });
    });
});
