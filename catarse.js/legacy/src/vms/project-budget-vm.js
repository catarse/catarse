import m from 'mithril';
import prop from 'mithril/stream';
import projectVM from './project-vm';
import generateErrorInstance from '../error';

const e = generateErrorInstance();

const fields = {
    budget: prop('')
};

const fillFields = (data) => {
    fields.budget(data.budget || '');
};

const updateProject = (project_id) => {
    const projectData = {
        budget: fields.budget()
    };

    return projectVM.updateProject(project_id, projectData);
};

const projectBudgetVM = {
    fields,
    fillFields,
    updateProject,
    e
};

export default projectBudgetVM;
