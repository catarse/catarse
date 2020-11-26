import m from 'mithril';
import prop from 'mithril/stream';
import projectVM from './project-vm';
import railsErrorsVM from './rails-errors-vm';
import generateErrorInstance from '../error';

const e = generateErrorInstance();

const fields = {
    about_html: prop(''),
    video_url: prop('')
};

const fillFields = (data) => {
    fields.about_html(data.about_html || '');
    fields.video_url(data.video_url || '');
};

const updateProject = (project_id) => {
    const projectData = {
        about_html: fields.about_html(),
        video_url: fields.video_url()
    };

    return projectVM.updateProject(project_id, projectData);
};

const projectDescriptionVM = {
    fields,
    fillFields,
    updateProject,
    e
};

export default projectDescriptionVM;

