import _ from 'underscore';
import m from 'mithril';
import prop from 'mithril/stream';
import inlineError from './c/inline-error';
// TODO: Define error pattern that comes from server-side and allow the lib
// to define what fields are coming with errors from the back-end
const generateErrorInstance = () => {
    const fields = prop([]);
    const submissionError = prop(false);
    const submissionErrorMsg = prop('');
    const fieldIdxValue = (fieldName, idx, initialValue) => _.reduce(fields(), (memo, field) => field[0] === fieldName ? field[idx] : memo, initialValue);

    const setError = (fieldName, flag) => {
        const updated = _.map(fields(), field => field[0] === fieldName ? [field[0], field[1], flag] : field);

        fields(updated);
    };

    const hasError = fieldName => fieldIdxValue(fieldName, 2, false);

    const getErrorMsg = fieldName => fieldIdxValue(fieldName, 1, '');

    const e = (fieldOrArray, errorMessage = '') => {
        if (Array.isArray(fieldOrArray)) {
            _.map(fieldOrArray, (field) => {
                field.push(false);
                return fields().push(field);
            });
        } else {
            fields().push([fieldOrArray, errorMessage, false]);
        }
    };

    e.fields = fields;
    e.setSubmissionError = submissionErrorMsg;
    e.hasSubmissionError = () => submissionError() === true;
    e.displaySubmissionError = () => {
        if (submissionError()) {
            return m('.card.card-error.u-radius.zindex-10.u-marginbottom-30.fontsize-smaller',
                     m('.u-marginbottom-10.fontweight-bold',
                       m.trust(submissionErrorMsg())
                      )
                    );
        }

        return null;
    };
    e.submissionError = (flag) => {
        if (_.isUndefined(flag)) {
            return e.displaySubmissionError();
        }

        submissionError(flag);
    };

    e.hasError = hasError;
    e.inlineError = (field, flag) => {
        if (_.isUndefined(flag)) {
            if (hasError(field)) {
                return m(inlineError, { message: getErrorMsg(field) });
            }

            return null;
        }
        setError(field, flag);
    };

    e.resetFieldErrors = () => _.map(fields(), field => field[2] = false);

    e.resetErrors = () => {
        e.resetFieldErrors();
        submissionError(false);
    };

    return e;
};

export default generateErrorInstance;
