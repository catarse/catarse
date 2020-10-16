import { ProjectsExploreViewModel } from '../../../src/vms/projects-explore-vm';

describe('ProjectExploreVM', () => {

    describe('find projects without city and state parameters', () => {
        beforeAll(() => {
            jasmine.Ajax.stubRequest(
                `${apiPrefix}/projects?order=open_for_contributions.desc%2Cstate_order.asc%2Cstate.desc%2Cscore.desc%2Cpledged.desc&state=eq.online&open_for_contributions=eq.true`
            ).andReturn({
                responseHeaders: {
                    'Content-Range': '0-2/2',
                },
                responseText: '[{"project_id":1},{"project_id":2}]',
            });
        });

        it('should return projects for default parameters', (done) => {
            const projectsExploreVM = new ProjectsExploreViewModel({
                mode: 'all_modes',
                category_id: null,
                searchParam: null,
                filter: 'all',
                cityState: null,
            });

            setInterval(() => {
                const totalAndCollectionAreEqual = projectsExploreVM.projectsView.total() === projectsExploreVM.projectsView.collection().length;
                if (totalAndCollectionAreEqual) {
                    done();
                }
            });
        });

        describe('projects found with category_id = 1', () => {

            beforeAll(() => {
                jasmine.Ajax.stubRequest(
                    `${apiPrefix}/projects?order=open_for_contributions.desc%2Cstate_order.asc%2Cstate.desc%2Cscore.desc%2Cpledged.desc&state=eq.online&category_id=eq.1&open_for_contributions=eq.true`
                ).andReturn({
                    responseHeaders: {
                        'Content-Range': '0-2/2',
                    },
                    responseText: '[{"project_id":1,"category_id":1},{"project_id":2,"category_id":1}]',
                });
            });

            it('should return projects within categories', (done) => {
                const projectsExploreVM = new ProjectsExploreViewModel({
                    mode: 'all_modes',
                    category_id: 1,
                    searchParam: null,
                    filter: 'all',
                    cityState: null,
                });
    
                setInterval(() => {
                    const totalAndCollectionAreEqual = projectsExploreVM.projectsView.total() === projectsExploreVM.projectsView.collection().length;
                    const totalProjectsWithCategoryId = projectsExploreVM.projectsView.collection().reduce((m, p) => p.category_id === 1 && m, true);
    
                    if (totalAndCollectionAreEqual && totalProjectsWithCategoryId) {
                        done();
                    }
                });
            });
        });

        describe('projects with mode sub, not_sub', () => {
            
            beforeAll(() => {
                jasmine.Ajax.stubRequest(
                    `${apiPrefix}/projects?order=open_for_contributions.desc%2Cstate_order.asc%2Cstate.desc%2Cscore.desc%2Cpledged.desc&state=eq.online&mode=eq.sub&open_for_contributions=eq.true`
                ).andReturn({
                    responseHeaders: {
                        'Content-Range': '0-2/2',
                    },
                    responseText: '[{"project_id":1,"mode":"sub"},{"project_id":2,"mode":"sub"}]',
                });

                jasmine.Ajax.stubRequest(
                    `${apiPrefix}/projects?order=open_for_contributions.desc%2Cstate_order.asc%2Cstate.desc%2Cscore.desc%2Cpledged.desc&state=eq.online&mode=eq.not.sub&open_for_contributions=eq.true`
                ).andReturn({
                    responseHeaders: {
                        'Content-Range': '0-2/2',
                    },
                    responseText: '[{"project_id":1,"mode":"flex"},{"project_id":2,"mode":"flex"}]',
                });
            });

            it('should find projects with mode sub', (done) => {
                const projectsExploreVM = new ProjectsExploreViewModel({
                    mode: 'sub',
                    category_id: null,
                    searchParam: null,
                    filter: 'all',
                    cityState: null,
                });
    
                setInterval(() => {
                    const totalAndCollectionAreEqual = projectsExploreVM.projectsView.total() === projectsExploreVM.projectsView.collection().length;
                    const totalProjectsWithModeSub = projectsExploreVM.projectsView.collection().reduce((m, p) => p.mode === 'sub' && m, true);
    
                    if (totalAndCollectionAreEqual && totalProjectsWithModeSub) {
                        done();
                    }
                });
            });

            it('should find projects with mode flex', (done) => {
                const projectsExploreVM = new ProjectsExploreViewModel({
                    mode: 'flex',
                    category_id: null,
                    searchParam: null,
                    filter: 'all',
                    cityState: null,
                });
    
                setInterval(() => {
                    const totalAndCollectionAreEqual = projectsExploreVM.projectsView.total() === projectsExploreVM.projectsView.collection().length;
                    const totalProjectsWithModeFlex = projectsExploreVM.projectsView.collection().reduce((m, p) => p.mode === 'flex' && m, true);
    
                    if (totalAndCollectionAreEqual && totalProjectsWithModeFlex) {
                        done();
                    }
                });
            });
        });
    });

    describe('projects from search params', () => {
        beforeAll(() => {
            jasmine.Ajax.stubRequest(
                `${apiPrefix}/rpc/project_search`
            ).andReturn({
                responseHeaders: {
                    'Content-Range': '0-2/2',
                },
                responseText: '[{"project_id":1,"mode":"sub","project_name":"test1"},{"project_id":2,"mode":"sub","project_name":"test2"}]',
            });
        });

        it('should find projects with mode sub and search param "test"', (done) => {
            const projectsExploreVM = new ProjectsExploreViewModel({
                mode: 'sub',
                category_id: null,
                searchParam: 'test',
                filter: 'all',
                cityState: null,
            });

            setInterval(() => {
                const totalAndCollectionAreEqual = projectsExploreVM.projectsView.total() === projectsExploreVM.projectsView.collection().length;
                const totalProjectsWithModeSubAndSearchParamTest = projectsExploreVM.projectsView.collection().reduce((m, p) => p.mode === 'sub' && p.project_name.indexOf('test') >= 0 && m, true);
                if (totalAndCollectionAreEqual && totalProjectsWithModeSubAndSearchParamTest) {
                    done();
                }
            });
        });
    });

    describe('find number of projects when searching by city', () => {

        beforeAll(() => {
            jasmine.Ajax.stubRequest(
                `${apiPrefix}/projects?order=open_for_contributions.desc%2Cstate_order.asc%2Cstate.desc%2Cscore.desc%2Cpledged.desc&state=eq.online&city_name=eq.CITY_NAME&select=project_id&open_for_contributions=eq.true`
            ).andReturn({
                responseHeaders: {
                    'Content-Range': '0-0/0',
                },
                responseText: '[]',
            });

            jasmine.Ajax.stubRequest(
                `${apiPrefix}/projects?order=open_for_contributions.desc%2Cstate_order.asc%2Cstate.desc%2Cscore.desc%2Cpledged.desc&state=eq.online&city_name=eq.CITY_NAME_2&select=project_id&open_for_contributions=eq.true`
            ).andReturn({
                responseHeaders: {
                    'Content-Range': '0-1/1'
                },
                responseText: '[{"project_id":1}]',
            });
        });


        it('should retrieve number of projects on searched city and on state when there is no project on the city', (done) => {
            const projectsExploreVM = new ProjectsExploreViewModel({
                mode: 'all_modes',
                category_id: null,
                searchParam: null,
                filter: 'all',
                cityState: {
                    city: {
                        name: 'CITY_NAME',
                    },
                    state: {
                        acronym: 'STATE_ACRONYM',
                    }
                }
            });

            setInterval(() => {
                if (projectsExploreVM.projectsView.collection()) {
                    expect(projectsExploreVM.amountFoundOnLocation).toBe(0);
                    done();
                }
            });
        });

        it('should retrieve number of projects on searched city and on state', (done) => {
            const projectsExploreVM = new ProjectsExploreViewModel({
                mode: 'all_modes',
                category_id: null,
                searchParam: null,
                filter: 'all',
                cityState: {
                    city: {
                        name: 'CITY_NAME_2',
                    },
                    state: {
                        acronym: 'STATE_ACRONYM_2',
                    }
                }
            });

            setInterval(() => {
                if (projectsExploreVM.amountFoundOnLocation === 1) {
                    done();
                }
            });
        });
    });
});