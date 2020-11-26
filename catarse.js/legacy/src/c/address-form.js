import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';
import nationalityRadio from '../c/nationality-radio';
import addressVM from '../vms/address-vm';
import addressFormInternational from './address-form-international';
import addressFormNational from './address-form-national';

const addressForm = {
    oninit: function(vnode) {
        const parsedErrors = vnode.attrs.parsedErrors;
        const statesLoader = catarse.loader(models.state.getPageOptions()),
            defaultCountryID = addressVM.defaultCountryID,
            defaultForeignCountryID = addressVM.defaultForeignCountryID,
            states = prop([]),
            zipCodeErrorMessage = prop(''),
            fields = vnode.attrs.addressFields,
            phoneMask = _.partial(h.mask, '(99) 9999-99999'),
            zipcodeMask = _.partial(h.mask, '99999-999'),
            applyZipcodeMask = (value) => fields.addressZipCode(zipcodeMask(value)),
            applyPhoneMask = (value) => fields.phoneNumber(phoneMask(value)),
            internationalProp = vnode.attrs.international ? vnode.attrs.international : prop(false),
            international = vnode.attrs.disableInternational ? prop(false) : internationalProp;

        const lookupZipCode = zipCode => {
            fields.addressZipCode(zipCode);
            if (zipCode.length === 9) {
                m.request({
                    method: 'GET',
                    url: `https://api.pagar.me/1/zipcodes/${zipCode}`,
                })
                    .then(response => {
                        fields.addressState(response.state);
                        fields.addressStreet(response.street);
                        fields.addressNeighbourhood(response.neighborhood);
                        fields.addressCity(response.city);
                        fields.stateID(_.find(states(), state => state.acronym === response.state).id);
                        fields.errors.addressStreet(false);
                        fields.errors.addressNeighbourhood(false);
                        fields.errors.addressCity(false);
                        fields.errors.stateID(false);
                        fields.errors.addressZipCode(false);
                    })
                    .catch(err => {
                        zipCodeErrorMessage(err.errors[0].message);
                        fields.errors.addressZipCode(true);
                    });
            }
        };

        statesLoader.load().then(data => {
            states(data);
            addressVM.states(states());
            fields.states(states());
            h.redraw();
        });
        
        vnode.state = {
            lookupZipCode,
            zipCodeErrorMessage,
            applyPhoneMask,
            applyZipcodeMask,
            defaultCountryID,
            defaultForeignCountryID,
            fields,
            international,
            states,
            parsedErrors
        };
    },
    view: function({ state, attrs }) {

        if (state.parsedErrors) {
            const parsedErrors = state.parsedErrors;
            state.fields.errors = {
                countryID: prop(parsedErrors ? parsedErrors.hasError('country_id') : false),
                stateID: prop(parsedErrors ? parsedErrors.hasError('state') : false),
                addressStreet: prop(parsedErrors ? parsedErrors.hasError('street') : false),
                addressNumber: prop(parsedErrors ? parsedErrors.hasError('number') : false),
                addressComplement: prop(false),
                addressNeighbourhood: prop(parsedErrors ? parsedErrors.hasError('neighbourhood') : false),
                addressCity: prop(parsedErrors ? parsedErrors.hasError('city') : false),
                addressState: prop(parsedErrors ? parsedErrors.hasError('state') : false),
                addressZipCode: prop(parsedErrors ? parsedErrors.hasError('zipcode') : false),
                phoneNumber: prop(parsedErrors ? parsedErrors.hasError('phonenumber') : false),
            };
        }

        const fields = state.fields,
            international = state.international,
            defaultCountryID = state.defaultCountryID,
            defaultForeignCountryID = state.defaultForeignCountryID,
            countryName = attrs.countryName,
            errors = state.fields.errors,
            applyZipcodeMask = state.applyZipcodeMask,
            lookupZipCode = state.lookupZipCode,
            zipCodeErrorMessage = state.zipCodeErrorMessage,
            countryStates = state.states,
            disableInternational = attrs.disableInternational,
            hideNationality = attrs.hideNationality,
            applyPhoneMask = state.applyPhoneMask;

        return m('#address-form.u-marginbottom-30.w-form', [
            !hideNationality
                ? m(
                    '.u-marginbottom-30',
                    m(nationalityRadio, {
                        fields,
                        defaultCountryID,
                        defaultForeignCountryID,
                        international,
                    })
                )
                : '',
            international()
                ? m(addressFormInternational, {
                    countryName,
                    fields,
                    disableInternational,
                    addVM: attrs.addVM,
                    international,
                    defaultCountryID,
                    defaultForeignCountryID,
                    errors,
                    applyPhoneMask,
                })
                : m(addressFormNational, {
                    disableInternational,
                    countryName,
                    fields,
                    international,
                    defaultCountryID,
                    defaultForeignCountryID,
                    errors,
                    applyZipcodeMask,
                    lookupZipCode,
                    zipCodeErrorMessage,
                    countryStates,
                    applyPhoneMask,
                }),
        ]);
    },
};

export default addressForm;
