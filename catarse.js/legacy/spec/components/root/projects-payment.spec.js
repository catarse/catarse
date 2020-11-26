import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
// import render from 'mithril-node-render';
import userVM from '../../../src/vms/user-vm';
import projectsPayment from '../../../src/root/projects-payment';

describe('ProjectsPayment', () => {
    let $output, $projectPaymentComponent;

    beforeAll(function() {
        const root = document.createElement('div');
        root.id = 'application';
        root.setAttribute('data-parameters', JSON.stringify(ProjectDetailsMockery()));
        root.setAttribute('data-contribution', JSON.stringify(ContributionMockery()));

        document.body.setAttribute('data-user', JSON.stringify(UserDetailMockery()[0]));
        document.body.appendChild(root);

        $output = mq(projectsPayment, {address: {international : prop(true)}});

    });

    describe('when contribution is international', () => {
        beforeAll(() => {
            // $output = mq(projectsPayment, {address: {international : prop(false)}});
            // $output.setValue('#country', 74);
        });

        it('should not show user document', () => {
            // expect($output.has('input#document')).toBeFalse();
        });
        it('should not show phone number', () => {
            // expect($output.has('input#phone')).toBeFalse();
        });
        it('should have address state as text input', () => {
            // expect($output.has('input#address-state')).toBeTrue();
            // expect($output.has('select#address-state')).toBeFalse();
        });
    });

    describe('when contribution is national', () => {
        beforeAll(() => {
            $output = mq(projectsPayment, {address: {international : prop(false)}});
            $output.setValue('#country', 36);
        });

        it('should show user document', () => {
            expect($output.has('input#document')).toBeTrue();
        });

        it('should show phone number', () => {
            expect($output.has('input#phone')).toBeTrue();
        });

        it('should have address state as select input', () => {

            expect($output.has('input#address-state')).toBeFalse();
            expect($output.has('select#address-state')).toBeTrue();
        });
    });
});
