import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.insights.campaign');

export const SolidarityProjectInsightsWelcomeDraft = {
    view() {
        return m.trust(I18n.t('solidarity_project_insights_welcome_draft_html', I18nScope()));
    }
}