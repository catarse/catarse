type ExtendedWindow = {
    replaceDiacritics(inputText : string): string;
}

import _ from 'underscore'
import { catarse } from '../api'
import models from '../models'
import h from '../h'
import projectFilters from './project-filters-vm'
import userVM from '../vms/user-vm'
import { SequencePaginationVM } from '../utils/sequence-pagination-vm'
import { Project } from '../entities/project'
import { ViewModel } from '../entities/view-model'
import { City } from '../entities/city'
import { State } from '../entities/state'
import { CityState } from '../entities/city-state'
import { searchCitiesGroupedByState } from '../vms/cities-search-vm'
import { SinglePageViewModel } from '../utils/single-page-vm'

const { replaceDiacritics } = window as any as ExtendedWindow;

interface Observer<T> {
    next(data: T): void;
    error?(err: Error): void;
};

const projectFiltersVM = projectFilters();

type Mode = 'all_modes' | 'sub' | 'not_sub' | 'covid_19';
export type Category = {
    name: string;
    id: number;
}

const ALL_CATEGORIES : Category = { name: 'Todas as categorias', id: null };
const filtersMap = projectFiltersVM.filters;
const filters = catarse.filtersVM;

export type ProjectsExploreVMSearchParams = {
    searchParam?: string;
    mode?: Mode;
    cityState?: CityState;
    category_id?: number;
    filter?: string;
}

export type Filter = {
    title: string;
    nicename?: string;
    filter: any;
    isContextual: boolean;
    keyName: string;
}

export type Query = {
    mode?: string,
    category_id?: number,
    state_acronym?: string,
    state_name?: string,
    city_name?: string,
    filter?: string,
}

export class ProjectsExploreViewModel {

    private _observer : Observer<Query>;
    private _categories : Category[];
    private _mode : Mode;
    private _category : Category;
    private _category_id : number;
    private _filter : string;
    private _cityState : CityState;
    private _searchParam : string;
    private _amountFoundOnLocation : number;
    private _projectsView : ViewModel<Project>;
    private _foundCityStates : CityState[];
    private _isLoadingLocationsSearch : boolean;
    private _lastQuery : Query;

    constructor(params : ProjectsExploreVMSearchParams) {

        this._observer = null;
        this._categories = [ALL_CATEGORIES];
        this._mode = params.mode || 'all_modes';
        this._category = this._categories[0];
        this._category_id = params.category_id || null;
        this._filter = params.filter || 'projects_we_love';
        this._cityState = params.cityState || null;
        this._searchParam = params.searchParam || '';
        this._amountFoundOnLocation = 0;

        this._projectsView = {
            collection: () => [],
            isLastPage: () => true,
            isLoading: () => false,
            nextPage: () => new Promise<Project[]>(() => {}),
            total: () => 0,
            firstPage: (p = {}) => new Promise<Project[]>(() => {}),
        };

        this._foundCityStates = [];
        this._lastQuery = this.mountQuery();
        this._isLoadingLocationsSearch = false;

        this.loadCategories();
        this.executeSearch();
    }

    async search(params : ProjectsExploreVMSearchParams) {
        this._mode = params.mode || 'all_modes';
        this._category_id = params.category_id || null;
        this._filter = params.filter || 'projects_we_love';
        this._cityState = params.cityState || null;
        this._searchParam = params.searchParam || '';

        if (this._category_id) {
            try {
                this._category = await this.getCategoryById(this._category_id);
                h.redraw();
            } catch(e) {
                this.category = ALL_CATEGORIES;
                this.dispatchNewQuery();
            }
        } else {
            this._category = ALL_CATEGORIES;
            h.redraw();
        }
        this.executeSearch();
    }

    subscribe(observer : Observer<Query>) {
        this._observer = observer;
    }

    get projectsView() : ViewModel<Project> {
        return this._projectsView;
    }

    async searchLocations(inputText : string) {
        let isLoaded = false;
        const loaderTimeout = setTimeout(() => {
            if (!isLoaded) {
                this._isLoadingLocationsSearch = true;
                h.redraw();
            }
        }, 100);
        this._foundCityStates = [];
        this._foundCityStates = await searchCitiesGroupedByState(inputText);
        isLoaded = true;
        clearTimeout(loaderTimeout);
        this._isLoadingLocationsSearch = false;
        h.redraw();
    }

    get foundLocations() : CityState[] {
        return this._foundCityStates;
    }

    get isLoadingLocationsSearch() : boolean {
        return this._isLoadingLocationsSearch;
    }

    get isTextSearch() : boolean {
        return this._searchParam !== '' && this._searchParam.length > 0;
    }

    set searchParam(value : string) {
        this._searchParam = value
        this.dispatchNewQuery();
    }

    get searchParam() : string {
        return this._searchParam;
    }

    set mode(mode : Mode) {
        this._mode = mode;
        if (mode === 'sub') {
            this._filter = 'all';
        } else if (mode === 'all_modes') {
            this._filter = 'projects_we_love';
        }
        this.dispatchNewQuery();
    }

    get mode() : Mode {
        return this._mode;
    }

    get modeName() : string {
        return filtersMap[this._mode].title;
    }

    set category(category : Category) {
        this._category = category;
        this._category_id = category.id;
        this.dispatchNewQuery();
        h.redraw();
    }

    get category() : Category {
        return this._category;
    }

    set category_id(category_id : number) {
        this._category_id = category_id;
        (async () => {
            try {
                this.category = await this.getCategoryById(category_id);
            } catch(e) {
                this.category = ALL_CATEGORIES;
            }
        })();
    }

    get category_id() {
        return this._category_id;
    }

    get categories() : Category[] {
        return this._categories;
    }

    set cityState(cityState : CityState) {
        this._cityState = cityState;
        this.dispatchNewQuery();
    }

    get cityState() : CityState{
        return this._cityState;
    }

    get amountFoundOnLocation() : number {
        return this._amountFoundOnLocation;
    }

    set filter(filter : string) {
        this._filter = filter;
        this.dispatchNewQuery();
    }

    get filter() {
        return this._filter;
    }

    get filterName() : string {
        return filtersMap[this._filter].nicename;
    }

    get filters() : Filter[] {
        return projectFiltersVM.getContextFilters();
    }

    private async getCategoryById(category_id : number) : Promise<Category> {
        return new Promise<Category>((resolve, reject) => {
            const category = this.findCagetoryById(category_id);
            if (category) {
                resolve(category);
            } else {
                const intervalWaitingCategoriesToLoad = setInterval(() => {
                    if (this._categories.length > 1) {
                        const category = this.findCagetoryById(category_id);
                        if (category) {
                            resolve(category);
                        } else {
                            reject(new Error('Category not found'));
                        }
                        clearInterval(intervalWaitingCategoriesToLoad);
                    }
                }, 100);
            }
        });
    }

    private findCagetoryById(category_id : number) : Category {
        return this._categories.find(c => c.id === category_id);
    }

    private async loadCategories() {
        models.category.pageSize(100);
        const params = filters({}).order({ name: 'asc' }).parameters();
        const categories = await models.category.getPageWithToken(params);
        this._categories = [ALL_CATEGORIES].concat(categories);
        const category = this._categories.find(c => c.id === this._category_id);

        if (category) {
            this._category = category;
        }
        h.redraw();
    }

    private dispatchNewQuery() {
        const newQuery = this.mountQuery();
        const queryIsDifferentFromLast = !_.isEqual(this._lastQuery, newQuery);
        if (queryIsDifferentFromLast) {
            this._lastQuery = newQuery;
            if (this._observer) {
                this._observer.next(newQuery);
            }
        }
    }

    private mountQuery() {

        const query : Query = { }

        if (this._mode !== 'all_modes') {
            query.mode = this._mode;
        }

        if (this._category_id) {
            query.category_id = this._category_id;
        }

        if (this._cityState) {
            query.state_acronym = this._cityState.state.acronym;
            query.state_name = this._cityState.state.state_name;

            if (this._cityState.city) {
                query.city_name = this._cityState.city.name;
            }
        }

        if (this._filter !== 'projects_we_love') {
            query.filter = this._filter;
        }

        return query;
    }

    private async executeSearch() {
        this.resetContextFilter();

        if (this._mode === 'sub') {
            projectFiltersVM.removeContextFilter(projectFiltersVM.filters.finished);
            projectFiltersVM.removeContextFilter(projectFiltersVM.filters.expiring);
            this._filter = 'all';
        }

        const model = this.getModelBasedOnFilter();
        const parameters = this.getParametersBaserOnFilter();
        this._projectsView = this.loadProjects(model, parameters);
        this.countProjectsOnCity(model, parameters);
        this._lastQuery = this.mountQuery();
        h.redraw();
    }

    private resetContextFilter() {
        const loggedInContextFilters = ['finished', 'projects_we_love', 'all', 'active_saved_projects', 'contributed_by_friends', 'expiring', 'recent', 'coming_soon_landing_page'];
        const notLoggedInContextFilters = ['finished', 'projects_we_love', 'all', 'expiring', 'recent', 'coming_soon_landing_page'];
        const contextFilters = userVM.isLoggedIn ? loggedInContextFilters : notLoggedInContextFilters;
        projectFiltersVM.setContextFilters(contextFilters);
    }

    private loadProjects(model, parameters : Object = {}) : ViewModel<Project> {
        model.pageSize(9);
        if (this._searchParam) {
            return new SinglePageViewModel(async () => {
                const projectsFound = await this.makeProjectsSearch()
                h.redraw()
                return projectsFound
            });
        } else if (this._cityState?.city?.name) {

            const cityOnlyVmInstance = catarse.paginationVM(model, null, { Prefer: 'count=exact' });
            const stateOnlyVmInstance = catarse.paginationVM(model, null, { Prefer: 'count=exact' });

            const cityOnlyPages = h.createBasicPaginationVMWithAutoRedraw(cityOnlyVmInstance);
            const stateOnlyPages = h.createBasicPaginationVMWithAutoRedraw(stateOnlyVmInstance);

            const cityOnlyParameters = {
                ...parameters,
                ...filters({ city_name: 'eq' }).city_name(this._cityState.city.name).parameters(),
            };
            const stateOnlyParameters = {
                ...parameters,
                ...filters({ state_acronym: 'eq', city_name: 'not.eq' }).state_acronym(this._cityState.state.acronym).city_name(this._cityState.city.name).parameters(),
            };

            cityOnlyPages.firstPage(cityOnlyParameters);
            stateOnlyPages.firstPage(stateOnlyParameters);

            const pageSize = 9;

            const vms = [cityOnlyPages, stateOnlyPages];

            return new SequencePaginationVM<Project>(vms, pageSize, model);
        } else {
            const vmInstance = catarse.paginationVM(model, null, { Prefer: 'count=exact' });
            const pages = h.createBasicPaginationVMWithAutoRedraw(vmInstance);
            pages.firstPage(parameters);
            return pages;
        }
    }

    private async makeProjectsSearch() : Promise<Project[]> {
        try {
            const response = await models.projectSearch.postWithToken({ query: replaceDiacritics(this._searchParam) })
            return response as Project[]
        } catch(e) {
            if (this._observer) {
                this._observer.error(e)
            }
        }
    }

    private async countProjectsOnCity(model, filterParameters : Object = {}) {
        try {
            if (this._cityState?.city?.name && _.isEmpty(this._searchParam)) {
                const parametersWithOnlyCityNotState = _.extend(
                    filterParameters,
                    filters({ city_name: 'eq' }).city_name(this._cityState.city.name).parameters()
                );
                this._amountFoundOnLocation = await this.countProjects(model, parametersWithOnlyCityNotState);
            }
        } catch(e) {
            this._amountFoundOnLocation = 0;
        } finally {
            h.redraw();
        }
    }

    private async countProjects(model, filterParameters: Object = {}) {
        model.pageSize(1);
        const selectMinimalFieldsFilterVM = catarse.filtersVM({ selectFields: 'select' });
        selectMinimalFieldsFilterVM.selectFields('project_id');
        const pages = catarse.paginationVM(model, null, { Prefer: 'count=exact' });
        const countParameters = _.extend(filterParameters, selectMinimalFieldsFilterVM.parameters());
        await pages.firstPage(countParameters);
        return pages.total();
    }

    private getModelBasedOnFilter() {
        return this._filter === 'finished' ? models.finishedProject : models.project;
    }

    private getParametersBaserOnFilter() {
        const modeFilter = filtersMap[this._mode];
        const filterFilter = filtersMap[this._filter];
        const parametersFilter = this.getParametersFromLocationSearchAndCategory();
        const order = this.filterOrderBasedOnFilter();

        return _.extend(
            modeFilter.filter.parameters(),
            filterFilter.filter.order(order).parameters(),
            this.setOpenForContribution(),
            parametersFilter
        );
    }

    private filterOrderBasedOnFilter() {
        if (this._filter === 'finished') {
            return {
                state_order: 'asc',
                state: 'desc',
                pledged: 'desc'
            };
        } else if (this._filter === 'coming_soon_landing_page')  {
            return {
                count_project_reminders: 'desc',
                updated_at: 'desc'
            };
        } else {
            return {
                open_for_contributions: 'desc',
                state_order: 'asc',
                state: 'desc',
                score: 'desc',
                pledged: 'desc'
            };
        }
    }

    private setOpenForContribution() {
        const skip_filter_open_for_contribution = ['finished', 'coming_soon_landing_page', 'active_saved_projects']

        if (!skip_filter_open_for_contribution.includes(this._filter)) {
            return filters({ open_for_contributions: 'eq' }).open_for_contributions(true).parameters();
        } else {
            return {};
        }
    }

    private getParametersFromLocationSearchAndCategory() {
        let parametersFilter = {};

        if (this._category_id) {
            parametersFilter = Object.assign(parametersFilter, filters({ category_id : 'eq' }).category_id(this._category_id).parameters());
        }

        const cityName = this._cityState?.city?.name;
        const stateAcronym = this._cityState?.state?.acronym;

        if (!cityName && stateAcronym) {
            parametersFilter = Object.assign(parametersFilter, filters({ state_acronym: 'eq' }).state_acronym(stateAcronym).parameters());
        }

        parametersFilter = Object.assign(parametersFilter, this.getOrParameters());

        return parametersFilter;
    }

    private getOrParameters() {
        if (this._searchParam) {
            return filters({
                textSearch: 'or'
            })
            .textSearch({
                full_text_index: {
                    plfts: this._searchParam,
                },
                project_name: {
                    plfts: this._searchParam,
                }
            }).parameters();
        } else {
            return {};
        }
    }
}
