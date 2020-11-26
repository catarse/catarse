import mq from 'mithril-query';
import m from 'mithril';
import _ from 'underscore';
import generateErrorInstance from '../../src/error';

const e = generateErrorInstance();

describe("error handler lib", () => {
    const submissionErrorMsg = 'submission error message';
    const hasAnyFieldError = () =>  _.reduce(e.fields(), (memo, field) => e.hasError(field) || memo, false);
    let componentify = (component) => {
        return mq(m({
            controller () {

            },
            view () {
                return component;
            }
        }));
    };

    describe("e initializer", () => {
        it("should set the fields names and error messages", () => {
            const count = e.fields().length;
            e('fieldName', 'error message');
            e('fieldName2', 'error message 2');
            e([
                ['fieldName3', 'error message 3'],
                ['fieldName4', 'error message 4']
            ]);
            expect(e.fields().length).toEqual(count + 4);
        });
    })
    describe("e.setSubmissionError", () => {
        it('should set the error message to show on submission errors', () => {
            e.setSubmissionError(submissionErrorMsg);
            e.submissionError(true);
            const $output = componentify(e.submissionError());
            expect($output.contains(submissionErrorMsg)).toBeTrue();
        });
    });
    describe('e.inlineError', () => {
        const inlineErrorFld = 'inlineErrorField';
        const inlineErrorMsg = 'Inline Field Error Message';

        it('should show the inline error message of a specific field, when only the field name is given and the error flag is true', () => {
            e(inlineErrorFld, inlineErrorMsg);
            e.inlineError(inlineErrorFld, true);
            const $output = componentify(e.inlineError(inlineErrorFld));
            expect($output.contains(inlineErrorMsg)).toBeTrue();
        });
        it('should set the error flag to false for the specified field, when field name and flag false are given', () => {
            e.inlineError(inlineErrorFld, false);
            expect(e.hasError(inlineErrorFld)).toBeFalse();
        });
        it('should set the error flag to true for the specified field, when field name and flag true are given', () => {
            e.inlineError(inlineErrorFld, true);
            expect(e.hasError(inlineErrorFld)).toBeTrue();
        });
    });
    describe('e.subsmissionError', () => {
        it('should set the submission error flag to false when parameter is false', () => {
            e.submissionError(false);
            expect(e.hasSubmissionError()).toBeFalse();;
        });
        it('should set the submission error flag to true when parameter is true', () => {
            e.submissionError(true);
            expect(e.hasSubmissionError()).toBeTrue();
        });
        it('should show the submission error message when called without parameters', () => {
            const $output = componentify(e.submissionError());
            expect($output.contains(submissionErrorMsg)).toBeTrue();
        });
    });
    describe('e.hasError', () => {
        const testField = 'testField';
        e(testField, 'error msg');

        it('should return true if field has it\'s error flag set to true', () => {
            e.inlineError(testField, true);
            expect(e.hasError(testField)).toBeTrue();
        });
        it('should return false if field has it\'s error flag set to false', () => {
            e.inlineError(testField, false);
            expect(e.hasError(testField)).toBeFalse();
        });
    });
    describe('e.hasSubmissionError', () => {
        it('should return true if submission has it\'s error flag set to true', () => {
            e.submissionError(true);
            expect(e.hasSubmissionError()).toBeTrue();
        });
        it('should return false if submission has it\'s error flag set to false', () => {
            e.submissionError(false);
            expect(e.hasSubmissionError()).toBeFalse();
        });
    });
    describe('e.resetFieldErrors', () => {
        it('should set the error flag of a all fields to false', () => {
            e.resetFieldErrors();
            expect(hasAnyFieldError()).toBeFalse();
        });
    });
    describe('e.resetErrors', () => {
        it('should set all the fields and the submission error flags to false', () => {
            e.resetErrors();
            expect(hasAnyFieldError()).toBeFalse();
            expect(e.hasSubmissionError()).toBeFalse();
        });
    });
});
