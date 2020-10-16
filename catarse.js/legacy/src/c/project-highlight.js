import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import projectShareBox from './project-share-box';
import facebookButton from './facebook-button';
import addressTag from './address-tag';
import categoryTag from './category-tag';
import { ProjectWeLovedTag } from './project-we-loved-tag';
import projectVM from '../vms/project-vm';
import projectVideo from './project-video';

const projectHighlight = {
    oninit: function(vnode) {
        vnode.state = {
            displayShareBox: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project;
        const isSub = projectVM.isSubscription(project);

        return m('#project-highlight', [
            (
                project().video_embed_url ? 
                    m(projectVideo, { video_embed_url : project().video_embed_url }) 
                :
                    m('.project-image', { style: `background-image:url('${project().original_image || project().project_img}');` })
            ),
            m('.w-hidden-small.w-hidden-tiny', [
                m(addressTag, { project, isDark: isSub }),
                m(categoryTag, { project, isDark: isSub }),
                project().recommended && m(ProjectWeLovedTag, { project, isDark: isSub }),
            ]),
            !isSub ? m('.project-blurb', project().headline) : null,
            m('.project-share.w-hidden-small.w-hidden-tiny',
                m('.u-marginbottom-30.u-text-center-small-only', [
                    m('.w-inline-block.fontcolor-secondary.fontsize-smaller.u-marginright-20',
                        'Compartilhar:'
                    ),
                    project().permalink ? m(facebookButton, {
                        class: isSub ? 'btn-terciary-negative' : null,
                        url: `https://www.catarse.me/${project().permalink}?ref=facebook&utm_source=facebook.com&utm_medium=social&utm_campaign=project_share`
                    }) : '',
                    project().permalink ? m(facebookButton, {
                        class: isSub ? 'btn-terciary-negative' : null,
                        messenger: true,
                        url: `https://www.catarse.me/${project().permalink}?ref=facebook&utm_source=facebook.com&utm_medium=messenger&utm_campaign=project_share`
                    }) : '',
                    m('button#more-share.btn.btn-inline.btn-medium.btn-terciary', {
                        class: isSub ? 'btn-terciary-negative' : null,
                        style: {
                            transition: 'all 0.5s ease 0s'
                        },
                        onclick: state.displayShareBox.toggle
                    }, [
                        '···',
                        ' Mais'
                    ]),
                    (state.displayShareBox() ? m(projectShareBox, {
                        project,
                        displayShareBox: state.displayShareBox
                    }) : '')
                ])
            )
        ]);
    }
};

export default projectHighlight;
