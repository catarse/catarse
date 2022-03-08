import _ from 'underscore';
import moment from 'moment';
import { catarse } from '../api';

const projectFiltersVM = () => {
    const filtersVM = catarse.filtersVM,
        covid19 = filtersVM({
            integrations: 'like',
        }).integrations('COVID-19'),

        all = filtersVM({
            state: 'eq'
        }).state('online'),

        nearMe = filtersVM({
            near_me: 'eq',
            open_for_contributions: 'eq'
        }).open_for_contributions('true').near_me(true),

        sub = filtersVM({
            mode: 'eq'
        }).mode('sub'),

        notSub = filtersVM({
            mode: 'not.eq'
        }).mode('sub'),

        expiring = filtersVM({
            expires_at: 'lte',
            open_for_contributions: 'eq'
        }).open_for_contributions('true').expires_at(moment().add(14, 'days').format('YYYY-MM-DD')),

        recent = filtersVM({
            online_date: 'gte',
            open_for_contributions: 'eq'
        }).open_for_contributions('true').online_date(moment().subtract(5, 'days').format('YYYY-MM-DD')),

        score = filtersVM({
            score: 'gte',
            open_for_contributions: 'eq'
        }).score('1').open_for_contributions('true'),

        online = filtersVM({
            open_for_contributions: 'eq'
        }).open_for_contributions('true'),

        active_saved_projects = filtersVM({
          active_saved_projects: 'eq'
        }).active_saved_projects(true),

        contributed_by_friends = filtersVM({
            open_for_contributions: 'eq',
            contributed_by_friends: 'eq'
        }).open_for_contributions('true').contributed_by_friends(true),

        successful = filtersVM({
            state: 'eq'
        }).state('successful'),

        coming_soon_landing_page = filtersVM({
            state: 'eq',
            integrations: 'like',
        }).state('draft').integrations('COMING_SOON_LANDING_PAGE'),

        finished = filtersVM({}),

        projects_we_love = filtersVM({
            recommended: 'eq'
        }).recommended(true),

        projects_we_love_not_sub = filtersVM({
            recommended: 'eq',
            mode: 'not.eq'
        }).recommended(true).mode('sub'),

        filters = {
            projects_we_love_not_sub: {
                title: 'Projetos que amamos',
                filter: projects_we_love_not_sub,
                mode: 'not_sub',
                nicename: 'Projetos que amamos',
                isContextual: false,
                keyName: 'projects_we_love',
                header_badges: ['badge-aon-h-margin', 'badge-flex-h-margin']
            },
            projects_we_love: {
                title: 'Projetos que amamos',
                filter: projects_we_love,
                nicename: 'Projetos que amamos',
                isContextual: false,
                keyName: 'projects_we_love',
                header_badges: ['badge-aon-h-margin', 'badge-flex-h-margin']
            },
            all: {
                title: 'Todas as Categorias',
                filter: all,
                nicename: 'Populares',
                isContextual: false,
                keyName: 'all'
            },
            covid_19: {
                title: 'Projetos COVID-19',
                filter: covid19,
                mode: 'covid_19',
                nicename: 'Projetos COVID-19',
                isContextual: false,
                keyName: 'covid_19',
                query: {
                    mode: 'covid_19',
                    filter: 'all'
                }
            },
            active_saved_projects: {
                title: 'Projetos Salvos',
                filter: active_saved_projects,
                nicename: 'Projetos Salvos',
                isContextual: false,
                keyName: 'active_saved_projects'
            },
            contributed_by_friends: {
                title: 'Amigos',
                filter: contributed_by_friends,
                nicename: 'Apoiados por amigos',
                isContextual: false,
                keyName: 'contributed_by_friends'
            },
            recent: {
                title: 'Recentes',
                filter: recent,
                nicename: 'Recentes',
                isContextual: false,
                keyName: 'recent'
            },
            expiring: {
                title: 'Reta final',
                filter: expiring,
                nicename: 'Reta final',
                isContextual: false,
                keyName: 'expiring'
            },
            finished: {
                title: 'Todas as Categorias',
                filter: finished,
                nicename: 'Finalizados',
                isContextual: false,
                keyName: 'finished'
            },
            score: {
                title: 'Todas as Categorias',
                filter: score,
                nicename: 'Populares',
                isContextual: false,
                keyName: 'score'
            },
            online: {
                title: 'No ar',
                filter: online,
                isContextual: false,
                keyName: 'online'
            },
            successful: {
                title: 'Todas as Categorias',
                filter: successful,
                nicename: 'Financiados',
                isContextual: false,
                keyName: 'successful'
            },
            coming_soon_landing_page: {
                title: 'Em breve no Catarse',
                filter: coming_soon_landing_page,
                nicename: 'Em breve no Catarse',
                isContextual: false,
                keyName: 'coming_soon_landing_page'
            },
            not_sub: {
                title: 'Projetos pontuais',
                nicename: 'Projetos pontuais',
                filter: notSub,
                isContextual: false,
                keyName: 'not_sub',
                header_badges: ['badge-aon-h-margin', 'badge-flex-h-margin']
            },
            all_modes: {
                title: 'Todos os projetos',
                filter: {
                    parameters: () => ({})
                },
                isContextual: false,
                keyName: 'all_modes'
            },
            sub: {
                title: 'Assinaturas',
                nicename: 'Assinaturas',
                filter: sub,
                mode: 'sub',
                isContextual: false,
                keyName: 'sub',
                header_badges: ['badge-sub-h-margin']
            },
            near_me: {
                title: 'Próximos a mim',
                filter: nearMe,
                isContextual: false,
                keyName: 'near_me'
            }
        };

    const setContextFilters = (contextFilters) => {
            _.map(contextFilters, filterKey => filters[filterKey].isContextual = true);

            return filters;
        },
        getContextFilters = () => _.filter(filters, filter => filter.isContextual),
        removeContextFilter = (filter) => {
            filters[filter.keyName].isContextual = false;

            return filters;
        };

    return {
        filters,
        setContextFilters,
        getContextFilters,
        removeContextFilter
    };
};

export default projectFiltersVM;
