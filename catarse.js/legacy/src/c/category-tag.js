import m from 'mithril';
import h from '../h';

const categoryTag = {
    view: function({attrs}) {
        const project = attrs.project;
        const categorySearchUrl = `/${window.I18n.locale}/explore?filter=all&category_id=${project().category_id}`;

        return project ? m(`a.btn.btn-inline.btn-small.btn-transparent.link-hidden-light${attrs.isDark ? '.fontcolor-negative' : ''}[href="${categorySearchUrl}"]`, {
            onclick: (/** @type {Event} */ event) => {
                h.analytics.event({
                    cat: 'project_view',
                    act: 'project_category_link',
                    lbl: project().category_name,
                    project: project()
                })(event);
                event.preventDefault();
                m.route.set(categorySearchUrl);
            }
        }, [
            m('span.fa.fa-tag'), ' ',
            project().category_name
        ]) : '';
    }
};

export default categoryTag;
