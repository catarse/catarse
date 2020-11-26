import { catarse } from '../api';
import _ from 'underscore';
import m from 'mithril';
import prop from 'mithril/stream';
import models from '../models';
import h from '../h';

const goals = prop([]),
    goalsData = prop([]),
    vm = catarse.filtersVM({
        project_id: 'eq'
    });

const goalsLoader = (projectId) => {
    vm.project_id(projectId);
    vm.order({
        value: 'asc'
    });

    return catarse.loaderWithToken(models.goalDetail.getPageOptions(vm.parameters()));
};

const addGoal = (projectId) => {
    goals().push(prop({
        id: prop(null),
        project_id: prop(projectId),
        editing: h.toggleProp(true, false),
        value: prop(''),
        title: prop(''),
        description: prop('')
    }));
};

const fetchGoals = projectId => goalsLoader(projectId).load().then(goalsRawData => {
    goalsData(goalsRawData);
    setTimeout(_ => {
        h.redraw();
    }, 1000);
});

const fetchGoalsEdit = (projectId) => {
    if (_.isEmpty(goals())) {
        goalsLoader(projectId).load().then((data) => {
            _.map(data, (goal) => {
                const goalProp = prop({
                    id: prop(goal.id),
                    project_id: prop(projectId),
                    editing: h.toggleProp(false, true),
                    value: prop(goal.value),
                    title: prop(goal.title),
                    description: prop(goal.description)
                });
                goals().push(goalProp);
            });
            if (_.isEmpty(goals())) {
                addGoal(projectId);
            }
        });
    }
};

const createGoal = (projectId, goalData) => m.request({
    method: 'POST',
    url: `/projects/${projectId}/goals.json`,
    data: { goal: goalData },
    config: h.setCsrfToken
});

const updateGoal = (projectId, goalId, goalData) => m.request({
    method: 'PATCH',
    url: `/projects/${projectId}/goals/${goalId}.json`,
    data: { goal: goalData },
    config: h.setCsrfToken
});

const projectGoalsVM = {
    goals,
    goalsData,
    fetchGoals,
    fetchGoalsEdit,
    addGoal,
    updateGoal,
    createGoal,
    goalsLoader
};

export default projectGoalsVM;
