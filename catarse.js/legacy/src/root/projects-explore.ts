/**
 * window.root.ProjectsExplore component
 * A root component to show projects according to user defined filters
 *
 * Example:
 * To mount this component just create a DOM element like:
 * <div data-mithril="ProjectsExplore">
 */
import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import UnsignedFriendFacebookConnect from '../c/unsigned-friend-facebook-connect';
import { CityState } from '../@types/city-state'
import { Category, Filter, ProjectsExploreViewModel, ProjectsExploreVMSearchParams } from '../vms/projects-explore-vm';
import { ExploreSearchFilterSelect } from '../c/explore/explore-search-filter-select';
import { ExploreFilterSelect } from '../c/explore/explore-filter-select';
import { ExploreProjectsFoundCounter } from '../c/explore/explore-projects-found-counter';
import { ExploreProjectsList } from '../c/explore/explore-projects-list';
import { ProjectsExplorerFooter } from '../c/projects-explore-footer';
import { ProjectsExploreLoadMoreButton } from '../c/projects-explore-load-more-button';
import { defineDeepObject } from '../utils/deep-object-operators';
import { ExploreSearchParam } from '../c/explore/explore-search-param';
import { ThisWindow } from '../@types/window';
import ExploreMobileSearch from '../c/explore/explore-mobile-search';

declare var window : ThisWindow

type ProjectExploreAttrs = {
    pg_search?: string
    mode?: string
    category_id?: number
    city_name?: string
    state_acronym?: string
    state_name?: string
    filter?: string
}

type ProjectExploreState = {
    projectsExploreVM: ProjectsExploreViewModel
    hasFBAuth: boolean
    hasSpecialFooter(category_id : number): boolean
    externalLinkCategories: {
        [category_id:number] : {
            icon: string
            title: string
            link: string
            cta: string
        }
    }
}

const I18nScope = _.partial(h.i18nScope, 'pages.explore');

const projectsExplore : m.Component<ProjectExploreAttrs, ProjectExploreState> = {

    oninit(vnode) {
        
        h.scrollTop();
        const currentUser = h.getUser() || {};
        const hasFBAuth = currentUser.has_fb_auth;
        const externalLinkCategories = window.I18n.translations[window.I18n.currentLocale()].projects.index.explore_categories;
        const hasSpecialFooter = categoryId => !_.isUndefined(externalLinkCategories[categoryId]);
        const projectsExploreVM = new ProjectsExploreViewModel(getProjectsViewQuery());

        window.addEventListener('popstate', () => {
            projectsExploreVM.search(getProjectsViewQuery());
        });

        window.addEventListener('pushstate', () => {
            projectsExploreVM.search(getProjectsViewQuery());
        });

        projectsExploreVM.subscribe({
            next(query) {
                
                h.scrollTop();

                const removeQueryParams = [
                    'mode',
                    'category_id',
                    'state_acronym',
                    'state_name',
                    'city_name',
                    'filter',
                ];
                
                h.setAndResetMultParamsArray(query, removeQueryParams);
            }
        });

        function getProjectsViewQuery() {
            const searchParam = h.paramByName('pg_search') || vnode.attrs.pg_search;
            const mode = h.paramByName('mode') || vnode.attrs.mode || 'all_modes';
            const filter = h.paramByName('filter') || vnode.attrs.filter || 'projects_we_love';
            const category_id = Number(h.paramByName('category_id')) || vnode.attrs.category_id || null;
            const cityState = getCityStateFromSearchParams();
    
            return {
                searchParam,
                mode,
                category_id,
                cityState: _.isEmpty(cityState) ? null : cityState,
                filter: mode === 'sub' ? 'all' : filter
            } as ProjectsExploreVMSearchParams;
        }

        function getCityStateFromSearchParams() : CityState {
            const city_name = h.paramByName('city_name') || vnode.attrs.city_name;
            const state_acronym = h.paramByName('state_acronym') || vnode.attrs.state_acronym;
            const state_name = h.paramByName('state_name') || vnode.attrs.state_name;

            const cityState = defineDeepObject('city.name', city_name);
            defineDeepObject('state.acronym', state_acronym, cityState);
            defineDeepObject('state.state_name', state_name, cityState);
            return cityState as CityState;
        };

        vnode.state = {
            projectsExploreVM,
            hasFBAuth,
            hasSpecialFooter,
            externalLinkCategories,
        };
    },
    onremove() {
        window.removeEventListener('popstate', window.onpopstate);
        window.removeEventListener('pushstate', window.onpushstate);
    },
    view({state, attrs}) {
        
        const projectsExploreVM : ProjectsExploreViewModel = state.projectsExploreVM;
        const projectsCollection = projectsExploreVM.projectsView.collection();
        const isContributedByFriendsFilter = projectsExploreVM.filter === 'contributed_by_friends';
        const hasSpecialFooter = state.hasSpecialFooter(projectsExploreVM.category_id);
        const showProjectsFoundCounter = !projectsExploreVM.projectsView.isLoading();
        const showConnectToFacebookButton = isContributedByFriendsFilter && _.isEmpty(projectsCollection) && !state.hasFBAuth;
        const showNextPageButton = !projectsExploreVM.projectsView.isLastPage() && !projectsExploreVM.projectsView.isLoading() && !_.isEmpty(projectsCollection);
        const specialFooterData = state.externalLinkCategories[projectsExploreVM.category_id] || { icon: '', title: '', link: '', cta: ''};
        const searchParam = state.projectsExploreVM.searchParam
        const hasSeachParam = !_.isEmpty(searchParam)

        const modes = [
            {
                label: 'Todos os projetos',
                value: 'all_modes',
            },
            {
                label: 'Projetos pontuais',
                value: 'not_sub',
            },
            {
                label: 'Assinaturas',
                value: 'sub',
            },
            {
                label: 'Projetos COVID-19',
                value: 'covid_19',
            },                        
        ];

        return m('#explore', {
            oncreate: h.setPageTitle(window.I18n.t('header_html', I18nScope()))
        }, [
            m('.hero-search.explore', [
                m('.u-marginbottom-10.w-container', m(ExploreMobileSearch)),
                m('.u-text-center.w-container', [
                    [
                        hasSeachParam ?
                            [
                                m('div', [
                                    m('.explore-text-fixed', 'Busca por'),
                                    m(ExploreSearchParam, {
                                        mobileLabel: 'BUSCA',
                                        searchParam,
                                        onClose: () => m.route.set('/pt/explore?filter=all')
                                    })
                                ])
                            ]
                            :
                            [
                                m('div', [
                                    m('.explore-text-fixed', 'Quero ver'),
                                    m(ExploreFilterSelect, {
                                        values: modes,
                                        mobileLabel: 'MODALIDADE',
                                        selectedItem: () => ({ label: projectsExploreVM.modeName, value: projectsExploreVM.mode }), 
                                        itemToString: (item : {label : string, value : string}) => item.label,
                                        isSelected: (item : {label : string, value : string}) => item.value === projectsExploreVM.mode,
                                        onSelect: (item) => projectsExploreVM.mode = item.value,
                                    }),
                                    m('.explore-text-fixed', 'de'),
                                    m(ExploreFilterSelect, {
                                        values: projectsExploreVM.categories,
                                        mobileLabel: 'CATEGORIA',
                                        splitNumberColumns: 2,
                                        selectedItem: () => projectsExploreVM.category,
                                        itemToString: (category : Category) => category.name,
                                        isSelected: (category : Category) => projectsExploreVM.category_id === category.id,
                                        onSelect: (category : Category) => projectsExploreVM.category = category,
                                    }),
                                ]),
                                m('div', [
                                    m('div.explore-text-fixed', 'localizados em'),
                                    m(ExploreSearchFilterSelect, {
                                        onSearch: (inputText : string) => projectsExploreVM.searchLocations(inputText),
                                        onSelect: (cityState : CityState) => projectsExploreVM.cityState = cityState,
                                        selectedItem: () => projectsExploreVM.cityState,
                                        foundItems: () => projectsExploreVM.foundLocations,
                                        noneSelected: 'Brasil',
                                        mobileLabel: 'LOCAL',
                                        isLoading: () => projectsExploreVM.isLoadingLocationsSearch,
                                        itemToString: (cityState : CityState) => {
                                            const firstPart = `${cityState.city ? cityState.city.name : cityState.state.state_name}`;
                                            const secondPart = `${cityState.city ? `, ${cityState.state.acronym}` : ' (Estado)'}`;
                                            return `${firstPart}${secondPart}`;
                                        },
                                    }),
                                    [
                                        projectsExploreVM.mode !== 'sub' && 
                                        [
                                            m('.explore-text-fixed', 'que são'),
                                            m(ExploreFilterSelect, {
                                                values: projectsExploreVM.filters,
                                                mobileLabel: 'FILTRO',
                                                selectedItem: () => ({
                                                    nicename: projectsExploreVM.filterName,
                                                    keyName: projectsExploreVM.filter
                                                } as { nicename : string, keyName : string }),
                                                itemToString: (item : Filter) => item.nicename,
                                                isSelected: (item : Filter) => projectsExploreVM.filter === item.keyName,
                                                onSelect: (item : Filter) => projectsExploreVM.filter = item.keyName,
                                            }),
                                        ]
                                    ]
                                ])
                            ]
                    ]
                ])
            ]), 
            [
                showProjectsFoundCounter &&
                m(ExploreProjectsFoundCounter, {
                    total: projectsExploreVM.projectsView.total(),
                }, [
                    projectsExploreVM.cityState?.city &&
                    m('div.fontsize-small.fontcolor-secondary.fontweight-semibold', [
                        m('span.fas.fa-map-marker-check.text-success'),
                        ` ${projectsExploreVM.amountFoundOnLocation || 'Nenhum'} em ${projectsExploreVM.cityState.city.name}, ${projectsExploreVM.cityState.state.acronym}  `,
                        '|',
                        ` ${(projectsExploreVM.projectsView.total() - projectsExploreVM.amountFoundOnLocation) || 'Nenhum'} em outras cidades de ${projectsExploreVM.cityState.state.acronym}`
                    ])
                ])
            ],
            [
                showConnectToFacebookButton &&
                m(UnsignedFriendFacebookConnect)
            ],
            m(ExploreProjectsList, {
                projects: projectsExploreVM.projectsView,
                isSearch: projectsExploreVM.isTextSearch,
                filterKeyName: projectsExploreVM.filter,
            }),
            m(ProjectsExploreLoadMoreButton, {
                showNextPageButton,
                onclick(event : Event) {
                    projectsExploreVM.projectsView.nextPage();
                    return false;
                }
            }),
            m(ProjectsExplorerFooter, {
                hasSpecialFooter,
                ...specialFooterData
            })
        ]);
    }
};

export default projectsExplore;
