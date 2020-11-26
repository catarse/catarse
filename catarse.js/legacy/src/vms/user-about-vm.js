import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import generateErrorInstance from '../error';

const e = generateErrorInstance();

const fields = {
    password: prop(''),
    current_password: prop(''),
    uploaded_image: prop(''),
    cover_image: prop(''),
    email: prop(''),
    permalink: prop(''),
    public_name: prop(''),
    facebook_link: prop(''),
    twitter: prop(''),
    links: prop([]),
    about_html: prop(''),
    email_confirmation: prop('')
};

const mapRailsErrors = (rails_errors) => {
    let parsedErrors;
    try {
        parsedErrors = JSON.parse(rails_errors);
    } catch (e) {
        parsedErrors = {};
    }
    const extractAndSetErrorMsg = (label, fieldArray) => {
        const value = _.first(_.compact(_.map(fieldArray, field => _.first(parsedErrors[field]))));

        if (value) {
            e(label, value);
            e.inlineError(label, true);
        }
    };

    extractAndSetErrorMsg('email', ['email']);
    extractAndSetErrorMsg('about_html', ['about_html']);

    return e;
};

const userAboutVM = {
    fields,
    mapRailsErrors
};

export default userAboutVM;
