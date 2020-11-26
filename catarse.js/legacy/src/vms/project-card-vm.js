import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import projectVM from './project-vm';
import generateErrorInstance from '../error';

const e = generateErrorInstance();
const currentProject = prop({});

const fields = {
    headline: prop(''),
    uploaded_image: prop(''),
    cover_image: prop(''),
    upload_files_targets: prop({}),
    upload_files: prop(new FormData())
};

const fillFields = (data) => {
    fields.headline(data.headline || '');
    fields.cover_image(data.cover_image || '');
    fields.upload_files_targets({});
    fields.upload_files(new FormData());
    currentProject(data);
};

const reloadCurrentProject = () => {
    if (currentProject().id) {
        projectVM.fetchProject(currentProject().id, false).then((data) => {
            fillFields(_.first(data));
            m.redraw();
        });
    }
};

const prepareForUpload = (event, target) => {
    const formData = fields.upload_files();
    if (event.target.files[0]) {
        if (formData.delete) formData.delete(target);
        formData.append(target, event.target.files[0]);
        fields.upload_files_targets()[target] = true;
    } else {
        formData.delete(target);
        delete fields.upload_files_targets()[target];
    }
};

const uploadImage = (project_id) => {
    if (_.isEmpty(fields.upload_files_targets())) {
        const p = new Promise((resolve) => {
            resolve({});
        });

        return p;
    }
    return m.request({
        method: 'POST',
        url: `/projects/${project_id}/upload_image.json`,
        data: fields.upload_files(),
        config: h.setCsrfToken,
        serialize(data) { return data; }
    });
};

const updateProject = (project_id) => {
    const projectData = {
        headline: fields.headline()
    };

    return projectVM.updateProject(project_id, projectData);
};

const projectCardVM = {
    fields,
    fillFields,
    updateProject,
    e,
    prepareForUpload,
    uploadImage,
    currentProject,
    reloadCurrentProject
};

export default projectCardVM;
