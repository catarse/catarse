import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import projectPosts from '../../src/c/project-posts';

describe('ProjectPosts', () => {
    let $output, projectPostDetail;

    describe('view', () => {
        beforeAll(() => {
            projectPostDetail = ProjectPostDetailsMockery()[0];
            const project = prop({id: 1231});
            const component = m(projectPosts, {
                    project: project
                });

            $output = mq(component);
        });

        it('should render project post list', () => {
            // expect($output.find('.post').length).toEqual(1);
            // expect($output.contains(projectPostDetail.title)).toEqual(true);
            pending();
        });
    });
});
