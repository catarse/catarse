import m from 'mithril';
import _ from 'underscore';
import userVM from '../vms/user-vm';
import projectVM from '../vms/project-vm';
import h from '../h';

const projectHeaderTitle = {
    view: function({attrs}) {
        const project = attrs.project,
            isSub = projectVM.isSubscription(project);

        return !_.isUndefined(project()) ? m(`.w-section.page-header${isSub ? '.transparent-background' : ''}`, [
            m('.w-container', [
                attrs.children,
                m('h1.u-text-center.fontsize-larger.fontweight-semibold.project-name[itemprop="name"]', h.selfOrEmpty(project().name || project().project_name)),
                !isSub ? m('h2.u-text-center.fontsize-base.lineheight-looser[itemprop="author"]', [
                    'por ',
                    project().user ? userVM.displayName(project().user) : (project().owner_public_name ? project().owner_public_name : project().owner_name)
                ]) : m('.w-row',
                    m('.w-col.w-col-6.w-col-push-3',
                        m('p.fontsize-small.lineheight-tight.u-margintop-10.u-text-center', project().headline)
                    )
                )
            ])
        ]) : m('div', '');
    }
};

export default projectHeaderTitle;
