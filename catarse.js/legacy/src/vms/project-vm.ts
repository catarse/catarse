import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse, commonAnalytics } from '../api';
import h from '../h';
import models from '../models';
import rewardVM from './reward-vm';
import projectGoalsVM from './project-goals-vm';
import userVM from './user-vm';
import Stream from 'mithril/stream';

const currentProject = prop(),
    userDetails = prop(),
    subscriptionData = prop(),
    projectContributions = prop([]),
    vm = catarse.filtersVM({ project_id: 'eq' }),
    idVM = h.idVM;

prop.merge([currentProject, userDetails, subscriptionData, projectContributions]).map(() => {
    h.redraw();
});

const isSubscription = (project = currentProject) => {
    if (_.isFunction(project)) {
        return project() ? project().mode === 'sub' : false;
    }

    return project ? project.mode === 'sub' : false;
};

const fetchSubData = projectUuid => {
    const lproject = commonAnalytics.loaderWithToken(models.projectSubscribersInfo.postOptions({ id: projectUuid }));

    lproject.load().then(data => {
        subscriptionData(
            data || {
                amount_paid_for_valid_period: 0,
                total_subscriptions: 0,
                total_subscribers: 0,
                new_percent: 0,
                returning_percent: 0,
            }
        );
        h.redraw();
    });
};

const setProject = project_user_id => data => {
    currentProject(_.first(data));
    if (isSubscription(currentProject())) {
        fetchSubData(currentProject().common_id);
    }

    if (!project_user_id) {
        userVM.fetchUser(currentProject().user_id, true, userDetails);
    }

    return currentProject;
};

const init = (project_id, project_user_id) => {
    vm.project_id(project_id);

    subscriptionData({
        amount_paid_for_valid_period: 0,
        total_subscriptions: 0,
        total_subscribers: 0,
        new_percent: 0,
        returning_percent: 0,
    });

    const lProject = catarse.loaderWithToken(models.projectDetail.getRowOptions(vm.parameters()));

    fetchParallelData(project_id, project_user_id);

    return lProject
        .load()
        .then(setProject(project_user_id))
        .then(() => h.redraw());
};

const resetData = () => {
    userDetails({});
    rewardVM.rewards([]);
};

const fetchParallelData = (projectId, projectUserId) => {
    if (projectUserId) {
        userVM.fetchUser(projectUserId, true, userDetails);
    }

    rewardVM.fetchRewards(projectId);
    projectGoalsVM.fetchGoals(projectId);
};

// FIXME: should work with data-parameters that don't have project struct
// just ids: {project_id project_user_id user_id }
const getCurrentProject = () => {
    const root = document.getElementById('application');
    const data = root && root.getAttribute('data-parameters');

    if (data) {
        const jsonData = JSON.parse(data);

        const { projectId, projectUserId } = jsonData; // legacy
        const { project_id, project_user_id } = jsonData;

        const project_data = {
            project_id: project_id || projectId,
            project_user_id: project_user_id || projectUserId,
        };

        // fill currentProject when jsonData has id and mode (legacy code)
        if (jsonData.id && jsonData.mode) {
            currentProject(project_data);
        }

        init(project_data.project_id, project_data.project_user_id);        

        h.redraw();

        return currentProject();
    }

    return false;
};

const routeToProject = (project, ref) => () => {
    currentProject(project);

    resetData();

    m.route.set(h.buildLink(project.permalink, ref), { project_id: project.project_id, project_user_id: project.project_user_id });

    return false;
};

const setProjectPageTitle = () => {
    if (currentProject()) {
        const projectName = currentProject().project_name || currentProject().name;

        return projectName ? h.setPageTitle(projectName) : Function.prototype;
    }
};

const fetchProject = (projectId, handlePromise = true, customProp = currentProject) => {
    idVM.id(projectId);

    const lproject = catarse.loaderWithToken(models.projectDetail.getRowOptions(idVM.parameters()));

    if (!handlePromise) {
        return lproject.load();
    } else {
        lproject
            .load()
            .then(
                _.compose(
                    customProp,
                    _.first
                )
            )
            .then(_ => m.redraw());
        return customProp;
    }
};

const updateProject = (projectId, projectData) =>
    m.request({
        method: 'PUT',
        url: `/projects/${projectId}.json`,
        data: { project: projectData },
        config: h.setCsrfToken,
    });

const subscribeActionKey = 'subscribeProject';
const storeSubscribeAction = route => {
    h.storeAction(subscribeActionKey, route);
};

const checkSubscribeAction = () => {
    const actionRoute = h.callStoredAction(subscribeActionKey);
    if (actionRoute) {
        m.route.set(actionRoute);
    }
};

const sendPageViewForCurrentProject = (project_id, eventsArray) => {

    const root = document.getElementById('application');
    const data = root && root.getAttribute('data-parameters');

    if (data) {
        const jsonData = JSON.parse(data);

        const { projectId, projectUserId } = jsonData; // legacy
        const { project_id, project_user_id } = jsonData;

        const project_data = {
            project_id: project_id || projectId,
            project_user_id: project_user_id || projectUserId,
        };

        loadIntegrationsAndSendPageView(project_data.project_id, eventsArray);
    } else if (project_id) {
        loadIntegrationsAndSendPageView(project_id, eventsArray);
    }
}

/**
 * @param {number} projectId 
 */
const loadIntegrationsAndSendPageView = async (projectId, eventsArray) => {

    try {
        const integrations = await getIntegrations(projectId);
        SendPageView(integrations, eventsArray);
    } catch(e) {
        h.captureException(e);
    }
}

/**
 * @typedef ProjectIntegration
 * @property {number} id
 * @property {string} name
 * @property {Object} data
 * @property {number} project_id
 */

/** @type {Stream< ProjectIntegration[] >} */
const integrations = prop([]);

/**
 * @param {number} projectId
 * @returns {Promise<ProjectIntegration[]>}
 */
const getIntegrations = (projectId) =>
    m.request({
        method: 'GET',
        config: h.setCsrfToken,
        url: `/projects/${projectId}/integrations.json`,
    });

/**
 * @typedef ProjectIntegrationResponse
 * @property {string} success
 * @property {number} integration_id
 */

/**
 * @param {number} projectId
 * @param {ProjectIntegration} integration
 * @returns {Promise<ProjectIntegrationResponse>}
 */
const createIntegration = (projectId, integration) =>
    m.request({
        method: 'POST',
        config: h.setCsrfToken,
        url: `/projects/${projectId}/integrations.json`,
        data: integration
    });

/**
 * @param {number} projectId
 * @param {ProjectIntegration} updatedIntegration
 * @returns {Promise<ProjectIntegrationResponse>}
 */
const updateIntegration = (projectId, updatedIntegration) =>
    m.request({
        method: 'PUT',
        config: h.setCsrfToken,
        url: `/projects/${projectId}/integrations/${updatedIntegration.id}.json`,
        data: updatedIntegration
    });

/**
 * @param {ProjectIntegration[]} projectIntegrations 
 */
const SendPageView = (projectIntegrations, eventsArray) => {

    for (const integration of projectIntegrations) {
        const trackingFunction = window.trackingFunctions[integration.name];

        if (trackingFunction) {
            trackingFunction(integration.data.id, eventsArray);
        }
    }
}

const ViewContentEvent = () => {
    return {
        event: 'ViewContent'
    }
}

const AddToCartEvent = () => {
    return {
        event: 'AddToCart'
    }
}

const PurchaseEvent = () => {
    return {
        event: 'Purchase'
    }
}

const SubscribeEvent = () => {
    return {
        event: 'Subscribe'
    }
}


const projectVM = {
    userDetails,
    getCurrentProject,
    projectContributions,
    currentProject,
    rewardDetails: rewardVM.rewards,
    goalDetails: projectGoalsVM.goalsData,
    routeToProject,
    setProjectPageTitle,
    init,
    fetchProject,
    fetchSubData,
    subscriptionData,
    updateProject,
    isSubscription,
    storeSubscribeAction,
    checkSubscribeAction,
    sendPageViewForCurrentProject,
    getIntegrations,
    createIntegration,
    updateIntegration,
    ViewContentEvent,
    AddToCartEvent,
    PurchaseEvent,
    SubscribeEvent,
};

export default projectVM;
