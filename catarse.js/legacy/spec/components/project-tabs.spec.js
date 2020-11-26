import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import projectTabs from '../../src/c/project-tabs';

describe('ProjectTabs', () => {
    let $output, projectDetail;

    describe('view', () => {
        beforeAll(() => {
            projectDetail = prop(ProjectDetailsMockery()[0]);
            let component = m(projectTabs, {
                project: prop(projectDetail),
                rewardDetails: prop([])
            });
            $output = mq(component);
        });

        it('should render project-tabs', () => {
            expect($output.find('a.dashboard-nav-link').length).toEqual(5);
            expect($output.find('a#about-link').length).toEqual(1);
        });

        it('should call hashMatch when click on some link', () => {
            const oldHash = window.location.hash;
            window.location.hash = 'posts';
            $output.redraw();
            $output.should.have('a#posts-link.selected');
            window.location.hash = oldHash;
        });
    });
});
