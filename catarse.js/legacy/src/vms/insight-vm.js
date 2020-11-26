import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.successful_onboard');

const parseAccountData = (account, transfer) => ({
    transfer_limit_date: h.momentify(account.transfer_limit_date),
    total_amount: h.formatNumber(transfer.total_amount, 2),
    bank_name: account.bank_name,
    agency: `${account.agency}${account.agency_digit ? `-${account.agency_digit}` : ''}`,
    account: `${account.account}${account.account_digit ? `-${account.account_digit}` : ''}`,
    user_email: account.user_email
});

const insightVM = {
    content(state, data) {
        const translations = window.I18n.translations[
            window.I18n.currentLocale()
        ].projects.successful_onboard[state],
            translationContext = (state === 'finished' ? {
                link_news: `/projects/${_.first(data.account()).project_id}/posts`
            } : parseAccountData(
                  _.first(data.account()),
                  _.first(data.transfer())
              ));
        let contentObj = {};

        _.map(translations, (translation, translationKey) => {
            contentObj = _.extend({}, contentObj, {
                [translationKey]: window.I18n.t(`${state}.${translationKey}`, I18nScope(translationContext))
            });
        });
        return contentObj;
    }
};

export default insightVM;
