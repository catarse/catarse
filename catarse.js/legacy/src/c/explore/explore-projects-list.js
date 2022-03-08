import m from 'mithril';
import _ from 'underscore';
import h from '../../h';
import projectCard from '../project-card';

export const ExploreProjectsList = {
    view({attrs}) {

        const projects = attrs.projects;
        const isSearch = attrs.isSearch;
        const filterKeyName = attrs.filterKeyName;
        const isContributedByFriendsFilter = (filterKeyName === 'contributed_by_friends');

        return m('.w-section.section', [
            m('.w-container', [
                m('.w-row', [
                    m('.w-row', _.map(projects.collection(), project => {
                        let cardType = 'small';
                        let ref = 'ctrse_explore';

                        if (isSearch) {
                            ref = 'ctrse_explore_pgsearch';
                        } else if (isContributedByFriendsFilter) {
                            ref = 'ctrse_explore_friends';
                        } else if (filterKeyName === 'all') {
                            if (project.score >= 1) {
                                ref = 'ctrse_explore_featured';
                            }
                        } else if (filterKeyName === 'active_saved_projects') {
                            ref = 'ctrse_explore_saved_project';
                        } else if (filterKeyName === 'projects_we_love') {
                            ref = 'ctrse_explore_projects_we_love';
                        }

                        return m(projectCard, {
                            project,
                            ref,
                            type: cardType,
                            showFriends: isContributedByFriendsFilter,
                        });
                    })),
                    projects.isLoading() ? h.loader() : ''
                ])
            ])
        ]);
    }
};
