import m from 'mithril';
import h from '../h';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import projectDescriptionEdit from './projects/edit/project-description-edit';
import projectDescriptionVideoEdit from './projects/edit/project-description-video-edit';

const projectEditDescription = {
    oninit: function(vnode) {
        vnode.state = {
            user: userVM.fetchUser(vnode.attrs.user_id),
            project: projectVM.fetchProject(vnode.attrs.project_id)
        };
    },

    view: function({state, attrs}) {
        const editComponent = projectVM.isSubscription(state.project)
            ? projectDescriptionVideoEdit
            : projectDescriptionEdit;
        return (state.user() && state.project() ? m(editComponent, {
            user: state.user(),
            userId: attrs.user_id,
            projectId: attrs.project_id,
            project: state.project()
        }) : m('div', h.loader()));
    }
};

export default projectEditDescription;
