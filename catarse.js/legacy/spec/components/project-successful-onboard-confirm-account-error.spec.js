import mq from 'mithril-query';
import m from 'mithril';
import projectSuccessfulOnboardConfirmAccountError from '../../src/c/project-successful-onboard-confirm-account-error';

describe('Project Successful Onboard Account Error', () => {
    let $output, changeActionFn, addErrorReasonFn;

    describe('view', () => {
        beforeAll(() => {
            changeActionFn = jasmine.createSpy('change-action');
            addErrorReasonFn = jasmine.createSpy('error-reason');

            let component = m(projectSuccessfulOnboardConfirmAccountError, {
                changeToAction: () => changeActionFn,
                addErrorReason: () => addErrorReasonFn
            });

            $output = mq(component);
        });

        it('should render a form', () => {
            expect($output.find('#successful-onboard-error').length).toEqual(1);
        });

        it('should call the error reason action on form submit', () => {
            $output.setValue('textarea', 'huhu');
            $output.click('.w-button.btn.btn-medium');
            expect(addErrorReasonFn).toHaveBeenCalled();
        });

        it('should not allow error reason submit with empty description', () => {
            $output.setValue('textarea', '');
            $output.click('.w-button.btn.btn-medium');
            expect($output.find('.text-error').length).toEqual(1);
        });

        it('should get back to action start when close is clicked', () => {
            $output.click('.fa-close');
            expect(changeActionFn).toHaveBeenCalled();
        });
    });
});
