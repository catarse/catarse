import m from 'mithril';
import h from '../h';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import projectBasicsEdit from '../c/project-basics-edit';

const projectEditBasic = {
    oninit: function(vnode) {
        const project = projectVM.fetchProject(vnode.attrs.project_id);
        async function reloadProject(projectProp) {
            try {
                await projectVM.fetchProject(vnode.attrs.project_id, true, projectProp);
                h.redraw();
            } catch(e) {
                console.log('Error loading project data:', e);
                h.captureException(e);
            }
        }

        vnode.state = {
            user: userVM.fetchUser(vnode.attrs.user_id),
            project,
            reloadProject,
        };
    },

    view: function({state, attrs}) {
        return (state.user() && state.project() ? m(projectBasicsEdit, {
            user: state.user(),
            userId: attrs.user_id,
            projectId: attrs.project_id,
            project: state.project(),
            reloadProject: state.reloadProject,
        }) : m('div', h.loader()));
    }
};

export default projectEditBasic;
