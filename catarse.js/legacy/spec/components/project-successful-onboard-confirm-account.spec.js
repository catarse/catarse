import mq from 'mithril-query';
import m from 'mithril';
import projectSuccessfulOnboardConfirmAccount from '../../src/c/project-successful-onboard-confirm-account';

describe('Project Successful Onboard Account Confirmation', () => {
    let $output;

    describe('view', () => {
        beforeAll(() => {

            $output = () => mq(projectSuccessfulOnboardConfirmAccount, {
                projectAccount: {
                    owner_document: ''
                },
                addErrorReason: Function.prototype,
                acceptAccount: Function.prototype,
                acceptAccountLoader: Function.prototype
            });

        });

        it('should render a confirmation dialog', () => {
            expect($output().find('#confirmation-dialog').length).toEqual(1);
        });

        it('should render the account accept component when clicking confirm', () => {
            let current = $output();

            current.click('#confirm-account');
            expect(current.find('#successful-onboard-form').length).toEqual(1);
        });
    });
});
