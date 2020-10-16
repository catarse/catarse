import _ from 'underscore';
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';

const railsErrors = prop('');
const setRailsErrors = errors => railsErrors(errors);
const errorGroups = {
    basics: ['public_name', 'permalink', 'category_id', 'city', 'public_tags', 'name', 'content_rating'],
    goal: ['goal', 'online_days'],
    goals: ['goals.size'],
    description: ['about_html'],
    budget: ['budget'],
    announce_expiration: ['online_days'],
    card: ['uploaded_image', 'headline'],
    video: ['video_url'],
    reward: ['rewards.size', 'rewards.minimum_value', 'rewards.title', 'rewards.description', 'rewards.deliver_at', 'rewards.shipping_fees.value', 'rewards.shipping_fees.destination'],
    user_about: ['user.uploaded_image', 'user.public_name', 'user.about_html'],
    user_settings: ['bank_account.id', 'bank_account.user_id', 'bank_account.account', 'bank_account.agency', 'bank_account.owner_name', 'bank_account.owner_document', 'bank_account.created_at', 'bank_account.updated_at', 'bank_account.account_digit', 'bank_account.agency_digit', 'bank_account.bank_id', 'bank_account.account_type', 'user.name', 'user.cpf', 'user.birth_date', 'user.country_id', 'user.address_state', 'user.address_street', 'user.address_number', 'user.address_city', 'user.address_neighbourhood', 'bank_account', 'user.phone_number']
};
const errorsFor = (group) => {
    let parsedErrors;
    try {
        parsedErrors = JSON.parse(railsErrors());
    } catch (err) {
        parsedErrors = {};
    }
    if (_.find(errorGroups[group], key => parsedErrors.hasOwnProperty(key))) { return m('span.fa.fa-exclamation-circle.fa-fw.fa-lg.text-error'); }
    if (_.isEmpty(parsedErrors)) { return ''; }
    return m('span.fa.fa-check-circle.fa-fw.fa-lg.text-success');
};

const mapRailsErrors = (rails_errors, errorsFields, e) => {
    let parsedErrors;
    try {
        parsedErrors = JSON.parse(rails_errors);
    } catch (err) {
        parsedErrors = {};
    }
    const extractAndSetErrorMsg = (label, fieldArray) => {
        const value = _.first(_.compact(_.map(fieldArray, field => _.first(parsedErrors[field]))));

        if (value) {
            e(label, value);
            e.inlineError(label, true);
        }
    };

    _.each(errorsFields, (item, i) => {
        if (item && item.length >= 2) {
            extractAndSetErrorMsg(item[0], item[1]);
        }
    });
};

// @FIXME: fix places where we call this
const validatePublish = () => {
    const currentProject = h.getCurrentProject();
    if (_.isEmpty(railsErrors())) { return false; }
    m.request({
        method: 'GET',
        url: `/projects/${currentProject.project_id}/validate_publish`,
        config: h.setCsrfToken
    }).then(() => { setRailsErrors(''); }).catch((err) => {
        if (err) {
            setRailsErrors(err.errors_json);
        }
        m.redraw();
    });
    return false;
};

const railsErrorsVM = {
    errorsFor,
    validatePublish,
    railsErrors,
    setRailsErrors,
    mapRailsErrors
};

export default railsErrorsVM;
