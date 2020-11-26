import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const addressTag = {
    view: function({attrs}) {
        const project = attrs.project;
        const address = project().address || { state_acronym: '', city: '' };
        const addressSearchUrl = `/${window.I18n.locale}/explore?filter=all&city_name=${address.city}&state_acronym=${address.state_acronym}`;
        
        return !_.isNull(address) ? m(`a.btn.btn-inline.btn-small.btn-transparent.link-hidden-light.u-marginbottom-10${attrs.isDark ? '.fontcolor-negative' : ''}[href="${addressSearchUrl}"]`, {
            onclick: (/** @type {Event} */ event) => {
                h.analytics.event({
                    cat: 'project_view',
                    act: 'project_location_link',
                    lbl: `${address.city} ${address.state_acronym}`,
                    project: project()
                })(event);
                event.preventDefault();
                m.route.set(addressSearchUrl);
            }
        }, [
            m('span.fa.fa-map-marker'), ` ${address.city}, ${address.state_acronym}`
        ]) : '';
    }
};

export default addressTag;
