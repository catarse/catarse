import m from 'mithril';
import h from '../h';
import projectReport from './project-report';

const projectComments = {
    oninit: function (vnode) {
        const loadComments = vnode => {
            h.fbParse();
        };

        vnode.state = { loadComments };
    },
    view: function ({ state, attrs }) {
        const project = attrs.project();
        return m('.w-row', [
            m('.w-col.w-col-7',
                m(`.fb-comments[data-href="http://www.catarse.me/${project.permalink}"][data-num-posts=50][data-width="610"]`, { oncreate: state.loadComments })
            ),
            m('.w-col.w-col-5', m(projectReport))
        ]);
    }
};

export default projectComments;
