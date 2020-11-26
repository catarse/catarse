import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const states = prop([]);
const countries = prop([]);
const defaultCountryID = 36;
const defaultForeignCountryID = 74;

const addressVM = (args) => {
    const data = args.data;
    const international = prop();
    const statesLoader = catarse.loader(models.state.getPageOptions());

    const fields = {
        id: prop(data.id || ''),
        countryID: prop(data.country_id || defaultCountryID),
        stateID: prop(data.state_id || ''),
        addressStreet: prop(data.address_street || ''),
        addressNumber: prop(data.address_number || ''),
        addressComplement: prop(data.address_complement || ''),
        addressNeighbourhood: prop(data.address_neighbourhood || ''),
        addressCity: prop(data.address_city || ''),
        addressState: prop(data.address_state || ''),
        addressZipCode: prop(data.address_zip_code || ''),
        phoneNumber: prop(data.phone_number || ''),
        states,
        countries
    };

    const errors = {
        countryID: prop(false),
        stateID: prop(false),
        addressStreet: prop(false),
        addressNumber: prop(false),
        addressComplement: prop(false),
        addressNeighbourhood: prop(false),
        addressCity: prop(false),
        addressState: prop(false),
        addressZipCode: prop(false),
        phoneNumber: prop(false),
    };

    fields.errors = errors;

    const exportData = {
        international,
        defaultCountryID,
        defaultForeignCountryID,
        fields,
        states,
        countries,
        errors
    };

    statesLoader.load().then(data => {
        states(data);
        h.redraw();
    });

    const setFields = (data) => {
        
        exportData.fields.id = prop(data.id || '');
        exportData.fields.countryID = prop(data.country_id || defaultCountryID);
        exportData.fields.stateID = prop(data.state_id || '');
        exportData.fields.addressStreet = prop(data.address_street || '');
        exportData.fields.addressNumber = prop(data.address_number || '');
        exportData.fields.addressComplement = prop(data.address_complement || '');
        exportData.fields.addressNeighbourhood = prop(data.address_neighbourhood || '');
        exportData.fields.addressCity = prop(data.address_city || '');
        exportData.fields.addressState = prop(data.address_state || '');
        exportData.fields.addressZipCode = prop(data.address_zip_code || '');
        exportData.fields.phoneNumber = prop(data.phone_number || '');
        international(Number(data.country_id) !== defaultCountryID);

        if (!_.isEmpty(states()) && !exportData.international()) {
            const countryState = _.first(_.filter(states(), countryState => {
                return exportData.fields.stateID() === countryState.id;
            }));
            
            if (countryState) {
                exportData.fields.addressState(countryState.acronym);
            }
        }
    };

    const getFields = () => {
        const isInternational = Number(exportData.fields.countryID()) !== defaultCountryID;

        if (!_.isEmpty(states()) && !isInternational) {
            const countryState = _.first(_.filter(states(), countryState => {
                return exportData.fields.stateID() === countryState.id;
            }));
            
            if (countryState) {
                exportData.fields.addressState(countryState.acronym);
            }
        }
        const data = {};
        // data.id = exportData.fields.id();
        data.country_id = exportData.fields.countryID();
        data.address_street = exportData.fields.addressStreet();

        if (!isInternational) {
            data.state_id = exportData.fields.stateID();
            data.address_number = exportData.fields.addressNumber();
            data.address_complement = exportData.fields.addressComplement();
            data.address_neighbourhood = exportData.fields.addressNeighbourhood();
            data.phone_number = exportData.fields.phoneNumber();
        }

        data.address_city = exportData.fields.addressCity();
        data.address_state = exportData.fields.addressState();
        data.address_zip_code = exportData.fields.addressZipCode();
        return data;
    };

    const checkPhone = () => {
        let hasError = false;
        const phone = fields.phoneNumber();
        const strippedPhone = String(phone || '').replace(/\D*/g, '');

        if (strippedPhone.length < 10) {
            errors.phoneNumber(true);
            hasError = true;
        } else {
            const controlDigit = Number(strippedPhone.charAt(2));
            if (!(controlDigit >= 2 && controlDigit <= 9)) {
                errors.phoneNumber(true);
                hasError = true;
            }
        }
        return hasError;
    };

    fields.validate = () => {
        let hasError = false;
        const fieldsToIgnore = international()
            ? ['id', 'stateID', 'addressComplement', 'addressNumber', 'addressNeighbourhood', 'phoneNumber']
            : ['id', 'addressComplement', 'addressState', 'phoneNumber'];
        // clear all errors
        _.mapObject(errors, (val, key) => {
            val(false);
        });
        // check for empty fields
        _.mapObject(_.omit(fields, fieldsToIgnore), (val, key) => {

            if (key !== 'validate' && key !== 'errors') {
                if (!val()) {
                    errors[key](true);
                    hasError = true;
                }
            }
        });
        if (!international()) {
            const hasPhoneError = checkPhone();
            hasError = hasError || hasPhoneError;
        }
        return !hasError;
    };

    exportData.setFields = setFields;
    exportData.getFields = getFields;

    return exportData;
};

addressVM.states = states;
addressVM.countries = countries;
addressVM.defaultCountryID = defaultCountryID;
addressVM.defaultForeignCountryID = defaultForeignCountryID;

export default addressVM;
