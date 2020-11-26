import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../../src/h';
import cancelProjectModalContent from '../../src/c/cancel-project-modal-content';

describe('cancelProjectModalContent', () => {
    let toggle, $output, project,
        c = window.c;

    describe('view', () => {
        beforeAll(() => {
            project = ProjectMockery()[0];
            toggle = h.toggleProp(true, false);
            $output = mq(m(cancelProjectModalContent, {
                displayModal: toggle,
                project
            }
                                    ));
        });

        it('should build a modal with .cancel-project-modal', function() {
            expect($output.has('.cancel-project-modal')).toBeTrue();
        });
    });
});
