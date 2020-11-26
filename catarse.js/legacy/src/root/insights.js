import m from 'mithril';
import prop from 'mithril/stream';
import { catarse, commonAnalytics } from '../api';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import projectInsights from '../c/project-insights';
import projectInsightsSub from '../c/project-insights-sub';

const insights = {
    oninit: function(vnode) {
        const filtersVM = catarse.filtersVM({
                project_id: 'eq'
            }),
            projectDetails = prop([]),
            subscribersDetails = prop(),
            load = prop(false),
            loader = catarse.loaderWithToken,
            isProjectNotLoader = prop(true),
            setProjectId = () => {
                try {
                    const project_id = m.route.param('project_id');

                    filtersVM.project_id(project_id);
                } catch (e) {
                    filtersVM.project_id(vnode.attrs.root.getAttribute('data-id'));
                }
            };

        setProjectId();
        const l = loader(models.projectDetail.getRowOptions(filtersVM.parameters()));

        l.load().then((data) => {
            projectDetails(data);
            if (_.first(data).mode === 'sub') {
                const l2 = commonAnalytics.loaderWithToken(models.projectSubscribersInfo.postOptions({
                    id: _.first(data).common_id
                }));
                l2.load().then((subData) => { 
                    subscribersDetails(subData); 
                    load(true); 
                    isProjectNotLoader(false);
                    h.redraw();
                })
                .catch(() => {
                    isProjectNotLoader(false);
                    h.redraw();
                });
            }
            else {
                isProjectNotLoader(false);
                h.redraw();
            }
        });
        vnode.state = {
            l,
            load,
            filtersVM,
            subscribersDetails,
            projectDetails,
            isProjectNotLoader
        };
    },
    view: function({state, attrs}) {
        const project = _.first(state.projectDetails()) || {
                user: {
                    name: 'Realizador'
                }
            },
            subscribersDetails = state.subscribersDetails() || {
                amount_paid_for_valid_period: 0,
                total_subscriptions: 0,
                total_subscribers: 0
            };

        if (!state.l()) {
            project.user.name = project.user.name || 'Realizador';
        }

        return m('.project-insights', state.isProjectNotLoader() ? h.loader() : (
            project.mode === 'sub' ?
                (
                    state.load() ?
                    m(projectInsightsSub, {
                        attrs,
                        subscribersDetails,
                        project,
                        l: state.isProjectNotLoader,
                        filtersVM: state.filtersVM
                    }) : '' 
                )
                    :
                (
                    m(projectInsights, {
                        attrs,
                        project,
                        l: state.isProjectNotLoader,
                        filtersVM: state.filtersVM
                    })
                )
        ));
    }
};

export default insights;
