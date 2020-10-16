import m from 'mithril';
import prop from 'mithril/stream';
import projectVM from './project-vm';
import generateErrorInstance from '../error';

const e = generateErrorInstance();

const fields = {
    mode: prop(''),
    online_days: prop(''),
    goal: prop(''),
    is_solidarity: prop(false),
    service_fee: prop(0.13),
};

const fillFields = (data) => {
    fields.mode(data.mode || 'aon');
    fields.online_days(data.online_days || '');
    fields.goal(data.goal);
    const projectSolidarityIntegration = (data.integrations || []).find(integration => integration.name === 'SOLIDARITY_SERVICE_FEE');
    fields.is_solidarity(!!projectSolidarityIntegration);
    fields.service_fee(data.service_fee);
};

const updateProject = (project_id) => {
    const projectData = {
        mode: fields.mode(),
        online_days: fields.online_days(),
        goal: fields.goal()
    };

    return projectVM.updateProject(project_id, projectData);
};

const genClickChangeMode = mode => () => {
    fields.mode(mode);
    fields.online_days('');
    if (mode == 'flex') {
        e.inlineError('online_days', false);
    }
};

const projectGoalVM = {
    fields,
    fillFields,
    updateProject,
    e,
    genClickChangeMode
};

export default projectGoalVM;
