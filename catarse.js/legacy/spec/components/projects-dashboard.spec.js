import mq from 'mithril-query';
import m from 'mithril';
import projectsDashboard from '../../src/root/projects-dashboard';

describe('ProjectsDashboard', () => {
    let $output, projectDetail;

    describe('view', () => {
        beforeAll(() => {
            // projectDetail = ProjectDetailsMockery()[0];
            // let component = m(projectsDashboard, {
            //     project_id: projectDetail.project_id,
            //     project_user_id: projectDetail.user.id,
            // });
            // $output = mq(component);
        });

        it('should render project about and reward list', () => {
            // expect($output.has('.project-nav-wrapper')).toBeTrue();
            pending();
        });
    });
});
