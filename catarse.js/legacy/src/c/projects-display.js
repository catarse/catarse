import m from 'mithril';
import prop from 'mithril/stream';
import projectFilters from '../vms/project-filters-vm';
import models from '../models';
import { catarse } from '../api';
import _ from 'underscore';
import h from '../h';
import projectRow from './project-row';
import projectRowWithHeader from './project-row-with-header';

const projectsDisplay = {
    oninit: function(vnode) {
        const EXPERIMENT_CASE_CURRENT = 'EXPERIMENT_CASE_CURRENT',
            EXPERIMENT_CASE_6SUBHOM = 'EXPERIMENT_CASE_6SUBHOM',
            EXPERIMENT_CASE_3SUBHOM = 'EXPERIMENT_CASE_3SUBHOM';

        // FIXED HOME CASE, 'EXPERIMENT_CASE_3SUBHOM'
        window.__GO_EXPE_NAME = EXPERIMENT_CASE_3SUBHOM;

        const filters = projectFilters().filters,
            currentCase = prop(window.__GO_EXPE_NAME == EXPERIMENT_CASE_CURRENT),
            subHomeWith6 = prop(window.__GO_EXPE_NAME == EXPERIMENT_CASE_6SUBHOM),
            subHomeWith3 = prop(window.__GO_EXPE_NAME == EXPERIMENT_CASE_3SUBHOM),
            sample3 = _.partial(_.sample, _, 3),
            loader = catarse.loaderWithToken,
            project = models.project,
            subHomeWith6CollectionsFilters = ['projects_we_love_not_sub', 'sub', 'covid_19', 'contributed_by_friends', 'coming_soon_landing_page'],
            windowEventNOTDispatched = true;

        project.pageSize(20);

        const collectionsMapper = (sampleNo, name) => {
            const f = filters[name],
                forSubPledged = name === 'sub' ? { pledged: 'gte.1000' } : {},
                defaultOptions = {
                    order: 'score.desc',
                    open_for_contributions: 'eq.true',
                    limit: '10',
                    offset: '0',
                },
                cLoader = loader(project.getPageOptions(_.extend(forSubPledged, defaultOptions, f.filter.parameters()))),
                collection = prop([]);

            cLoader
                .load()
                .then(
                    _.compose(
                        collection,
                        sampleNo
                    )
                )
                .then(() => m.redraw());

            const query = f.query || {};

            if (!f.query) {
                if (f.mode) {
                    query.mode = f.mode;
                } else {
                    query.filter = f.keyName;
                }
            }

            return {
                title: f.nicename,
                hash: name === 'score' ? 'all' : f.keyName,
                mode: f.mode,
                collection,
                query,
                loader: cLoader,
                showFriends: name === 'contributed_by_friends',
                badges: !_.isUndefined(f.header_badges) ? f.header_badges : [],
            };
        };

        const aonAndFlex_Sub_3 = _.map(subHomeWith6CollectionsFilters, collectionsMapper.bind(collectionsMapper, sample3));

        vnode.state = {
            aonAndFlex_Sub_3,
            currentCase,
            subHomeWith6,
            subHomeWith3,
            windowEventNOTDispatched,
        };
    },

    view: function({ state }) {
        if (state.windowEventNOTDispatched) {
            window.dispatchEvent(new Event('on_projects_controller_loaded'));
            state.windowEventNOTDispatched = false;
        }

        if (state.subHomeWith6()) {
            return m(
                'div',
                _.map(state.aonAndFlex_Sub_6, (collection, index) =>
                    m(projectRowWithHeader, {
                        collection,
                        title: collection.title,
                        ref: `home_${collection.hash === 'all' ? 'score' : collection.hash}`,
                        showFriends: collection.showFriends,
                        isOdd: index & 1,
                    })
                )
            );
        } else if (state.subHomeWith3()) {
            return m(
                'div',
                _.map(state.aonAndFlex_Sub_3, (collection, index) =>
                    m(projectRowWithHeader, {
                        collection,
                        title: collection.title,
                        ref: `home_${collection.hash === 'all' ? 'score' : collection.hash}`,
                        showFriends: collection.showFriends,
                        isOdd: index & 1,
                    })
                )
            );
        } else {
            return m(
                'div',
                _.map(state.collections, collection =>
                    m(projectRow, {
                        collection,
                        title: collection.title,
                        ref: `home_${collection.hash === 'all' ? 'score' : collection.hash}`,
                        showFriends: collection.showFriends,
                    })
                )
            );
        }
    },
};

export default projectsDisplay;
