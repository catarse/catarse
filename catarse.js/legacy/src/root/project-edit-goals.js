import m from 'mithril';
import h from '../h';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import projectGoalsEdit from '../c/project-goals-edit';

const projectEditGoals = {
    oninit: function(vnode) {
        vnode.state = {
            user: userVM.fetchUser(vnode.attrs.user_id),
            project: projectVM.fetchProject(vnode.attrs.project_id)
        };
    },

    view: function({state, attrs}) {
        return (state.user() && state.project() ? (state.project().mode !== 'sub' ? '' : m(projectGoalsEdit, {
            user: state.user(),
            userId: attrs.user_id,
            projectId: attrs.project_id,
            project: state.project()
        })) : m('div', h.loader()));
    }
};

export default projectEditGoals;
