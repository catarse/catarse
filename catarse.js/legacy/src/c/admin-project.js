import m from 'mithril';
import h from '../h';

const adminProject = {
    view: function({attrs}) {
        const project = attrs.item;
        return m('.w-row.admin-project', [
            m('.w-col.w-col-3.w-col-small-3.u-marginbottom-10', [
                m(`img.thumb-project.u-radius[src=${project.project_img}][width=50]`)
            ]),
            m('.w-col.w-col-9.w-col-small-9', [
                m('.fontweight-semibold.fontsize-smaller.lineheight-tighter.u-marginbottom-10', [
                    m(`a.alt-link[target="_blank"][href="/${project.permalink}"]`, project.project_name)
                ]),
                m('.fontsize-smallest.fontweight-semibold', project.project_state),
                m('.fontsize-smallest.fontcolor-secondary', `${h.momentify(project.project_online_date)} a ${h.momentify(project.project_expires_at)}`)
            ])
        ]);
    }
};

export default adminProject;
