import m from 'mithril';
import mq from 'mithril-query';
import projectMain from '../../src/c/project-main';
import h from '../../src/h';

describe('ProjectMain', () => {

    describe('view', () => {
        
        describe('mobile', () => {

            let component = null;
            let attrs = {
                project() {
                    return {};
                },
                rewardDetails() {
                    return [];
                },
                hasSubscription: () => false,
            };

            beforeEach(() => {
                // activate mobile
                spyOnProperty(window.screen, 'width').and.returnValue(500);
                window.dispatchEvent(new Event('resize'));

                component = mq(m(projectMain, attrs));
            });

            it('should display rewards suggestions of 10, 25, 50, 100', () => {
                component.should.have('#suggestions .fontsize-jumbo:contains(10)');
                component.should.have('#suggestions .fontsize-jumbo:contains(25)');
                component.should.have('#suggestions .fontsize-jumbo:contains(50)');
                component.should.have('#suggestions .fontsize-jumbo:contains(100)');
            });

            it('should display rewads list', () => {
                attrs.rewardDetails = () => ([
                    {
                        id: 100,
                        minimum_value: 10,
                        uploaded_image: 'image.png',
                        description: 'reward description',
                    }
                ]);
                component = mq(m(projectMain, attrs));

                component.should.have(`img[src='${attrs.rewardDetails()[0].uploaded_image}']`);
                component.should.have('#rewards');
                component.should.contain(`Para R$ ${h.formatNumber(10)}`);
            });
        });
        
        describe('desktop', () => {
            let component = null;
            let attrs = {
                project() {
                    return {
                        budget: 'budget',
                    };
                },
                rewardDetails() {
                    return [];
                },
                hasSubscription: () => false,
            };

            beforeEach(() => {
                // activate desktop
                spyOnProperty(window.screen, 'width').and.returnValue(1024);
                window.dispatchEvent(new Event('resize'));

                component = mq(m(projectMain, attrs));
            });

            it('should display about', () => {
                component.should.have(`#project-about`);
            });
        });
    });
});
