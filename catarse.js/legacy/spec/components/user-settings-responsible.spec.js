import mq from 'mithril-query';
import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../../src/h';
import userSettingsResponsible from '../../src/c/user-settings-responsible';

describe('UserSettingsResponsible', () => {
    let $output;
    const 
        disableFields = false,
        fields = prop({
            account_type: prop('pf'),
            name: prop('USER NAME'),
            owner_document: prop('12345678912'),
            birth_date: prop('02/12/1990'),
            state_inscription: prop('123456789')
        }),
        parsedErrors = {
            hasError: function(name) {
                return false;
            },
            inlineError: function(name) {
                return false;
            }
        },
        birthDayMask = _.partial(h.mask, '99/99/9999'),
        documentMask = _.partial(h.mask, '999.999.999-99'),
        documentCompanyMask = _.partial(h.mask, '99.999.999/9999-99'),
        applyBirthDateMask = _.compose(fields().birth_date, birthDayMask),
        applyDocumentMask = (value) => {
            if (fields().account_type() != 'pf') {
                fields().owner_document(documentCompanyMask(value));
            } else {
                fields().owner_document(documentMask(value));
            }
        },
        user = {
            birth_date : '02/12/1990'
        };

    describe('view', () => {

        beforeAll(() => {
            $output = mq(m(userSettingsResponsible, { parsedErrors, fields, user, disableFields, applyDocumentMask, applyBirthDateMask }));
        });

        it('should show selection of account type', () => {
            expect($output.find('select.select.required.w-input.text-field.bank-select').length == 1).toBeTrue();
        });

        it('should show input field for user account name', () => {
            expect($output.find('#user_bank_account_attributes_owner_name').length == 1).toBeTrue();
        });

        it('should show fields for document and birth date', () => {
            expect($output.find('input.string.tel.required.w-input.text-field').length == 2).toBeTrue();
        });
    });
});
