import mq from 'mithril-query';
import m from 'mithril';
import projectCancelButton from '../../src/c/project-cancel-button';

describe('ProjectCancelButton', () => {
    let project, $output,
        c = window.c;

    describe('view', () => {
        beforeAll(() => {
            project = ProjectMockery()[0];
            $output = mq(m(projectCancelButton, {
                project,
                category: {
                    project
                }
            }));
        });

        it('should build a link with .btn-cancel', function() {
            expect($output.has('button.btn-cancel')).toBeTrue();
        });

        it('should open project cancel modal when clicked', () => {
            $output.click('button.btn-cancel');
            $output.should.have('.cancel-project-modal');
        });
    });
});
