import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects');

export const SolidarityProjectDescription = {
    view({ attrs }) {
        const percentage = attrs.percentage;
        return m.trust(I18n.t('solidarity_taxes_description_html', I18nScope({ percentage })));
    }
}