import mq from 'mithril-query';
import m from 'mithril';
import h from '../../src/h';
import projectCard from '../../src/c/project-card';

describe('ProjectCard', () => {
    let project, component, view, $output, $customOutput, remainingTimeObj;

    describe('view', () => {
        beforeAll(() => {
            project = ProjectMockery()[0];
            remainingTimeObj = h.translatedTime(project.remaining_time);
            $output = (type) => mq(m(projectCard, {
                project: project, type: type
            }));
        });

        it('should render the project card', () => {
            expect($output().find('.card-project').length).toEqual(1);
            expect($output().contains(project.owner_name)).toEqual(true);
            expect($output().contains(remainingTimeObj.unit)).toEqual(true);
        });

        it('should render a big project card when type is big', () => {
            expect($output('big').find('.card-project-thumb.big').length).toEqual(1);
            expect($output('big').contains(project.owner_name)).toEqual(true);
            expect($output('big').contains(remainingTimeObj.unit)).toEqual(true);
        });

        it('should render a medium project card when type is medium', () => {
            expect($output('medium').find('.card-project-thumb.medium').length).toEqual(1);
            expect($output('medium').contains(project.owner_name)).toEqual(true);
            expect($output('medium').contains(remainingTimeObj.unit)).toEqual(true);
        });
    });
});
