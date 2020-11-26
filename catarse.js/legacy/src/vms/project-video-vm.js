import m from 'mithril';
import prop from 'mithril/stream';
import projectVM from './project-vm';
import generateErrorInstance from '../error';

const e = generateErrorInstance();

const fields = {
    video_url: prop('')
};

const fillFields = (data) => {
    fields.video_url(data.video_url || '');
};

const updateProject = (project_id) => {
    const projectData = {
        video_url: fields.video_url()
    };

    return projectVM.updateProject(project_id, projectData);
};

const projectVideoVM = {
    fields,
    fillFields,
    updateProject,
    e
};

export default projectVideoVM;
