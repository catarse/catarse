import mq from 'mithril-query';
import m from 'mithril';
import teamMembers from '../../src/c/team-members';

describe('TeamMembers', () => {
    let $output;

    describe('view', () => {
        beforeAll(() => {
            var groupCollection = (collection, groupTotal) => _.map(_.range(Math.ceil(collection.length / groupTotal)), i => collection.slice(i * groupTotal, (i + 1) * groupTotal));
            $output = mq(m(teamMembers, {team_members : groupCollection(TeamMembersMockery(10), 10)}));
        });

        it('should render fetched team members', () => {
            expect($output.has('#team-members-static.w-section.section')).toEqual(true);
            expect($output.find('.team-member').length).toEqual(TeamMembersMockery(10).length);
        });
    });
});
