import mq from 'mithril-query';
import projectsHome from '../../../src/root/projects-home'

describe('ProjectsHome', () => {

    describe('view', () => {

        let $homeComponent;

        beforeAll(() => {
            $homeComponent = mq(m(projectsHome));
        });

        it('should render home header', () => {
            expect($homeComponent.find('#projects-home-component')).toBeDefined()
        });
    });
});
