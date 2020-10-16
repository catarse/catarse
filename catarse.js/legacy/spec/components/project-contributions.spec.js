import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import projectContributions from '../../src/c/project-contributions';

describe('projectContributions', () => {
    let $output, projectContribution;

    describe('view', () => {
        beforeAll(() => {
            jasmine.Ajax.stubRequest(new RegExp("("+apiPrefix + '\/contributors)'+'(.*)')).andReturn({
                'responseText' : JSON.stringify(ContributorMockery())
            });

            projectContribution = ContributorMockery()[0];
            const project = prop({
                        id: 1231
            });

            $output = mq(projectContributions, {
                project: project
            });
        });

        it('should render project contributions list', () => {
            // expect($output.contains(projectContribution.data.name)).toEqual(true);
            pending();
        });
    });
});
