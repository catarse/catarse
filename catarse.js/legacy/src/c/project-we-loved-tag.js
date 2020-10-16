import m from 'mithril';
import h from '../h';

export const ProjectWeLovedTag = {
    view({attrs}) {
        const project = attrs.project;
        const isDark = attrs.isDark;
        const filterSearchUrl = `/${window.I18n.locale}/explore?filter=projects_we_love`;

        return m(`a.btn.btn-small.btn-inline.btn-transparent.link-hidden-light.u-marginbottom-10.w-inline-block[href="${filterSearchUrl}"]`, {
            onclick: (/** @type {Event} */ event) => {
                h.analytics.event({
                    cat: 'project_view',
                    act: 'projects_we_love_link',
                    lbl: `${project().name} projects_we_love`,
                    project: project()
                })(event);
                event.preventDefault();
                m.route.set(filterSearchUrl);
            }
        }, [
            m('img[src="https://uploads-ssl.webflow.com/5849f4f0a275a2a744efd93e/5e6ee98114890713cbd0c3d1_ctrse_heart_icon.png"][width="20"][alt=""]'),
            m(`div.inline-block.link-hidden-light${isDark ? '.fontcolor-negative' : ''}`, 'Projeto que Amamos')
        ]);
    }
}