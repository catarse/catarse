import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import projectVM from '../vms/project-vm';
import addressVM from '../vms/address-vm';
import models from '../models';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit.errors');
const paymentInfoId = prop();
const { commonPayment, commonSubscriptionUpgrade, commonPaymentInfo, commonCreditCard, commonCreditCards, rechargeSubscription } = models;
const sendPaymentRequest = data => commonPayment.postWithToken(
    { data: _.extend({}, data, { payment_id: paymentInfoId() }) },
    null,
    (h.isDevEnv() ? { 'X-forwarded-For': '127.0.0.1' } : {})
)
.catch((error) => {
    h.captureException(error);
    throw error;
});

const sendSubscriptionUpgrade = data => commonSubscriptionUpgrade.postWithToken(
    { data },
    null,
    (h.isDevEnv() ? { 'X-forwarded-For': '127.0.0.1' } : {})
)
.catch((error) => {
    h.captureException(error);
    throw error;
});

const saveCreditCard = creditCardHash => commonCreditCard
.postWithToken({ data: { card_hash: creditCardHash } })
.catch((error) => {
    h.captureException(error);
    throw error;
});;

const updateUser = user => m.request({
    method: 'PUT',
    url: `/users/${user.id}.json`,
    data: {
        user
    },
    config: h.setCsrfToken
})
.catch((error) => {
    h.captureException(error);
    throw error;
});

const userPayload = (customer, address) => ({
    id: h.getUser().id,
    cpf: customer.ownerDocument(),
    name: customer.completeName(),
    address_attributes: {
        country_id: address.country_id,
        state_id: address.state_id,
        address_street: address.address_street,
        address_neighbourhood: address.address_neighbourhood,
        address_number: address.address_number,
        address_zip_code: address.address_zip_code,
        address_city: address.address_city,
        address_state: address.address_state,
        address_complement: address.address_complement,
        phone_number: address.phone_number
    }
});

const displayError = fields => (exception) => {
    const errorMsg = exception.message || window.I18n.t('submission.encryption_error', I18nScope());
    fields.isLoading(false);
    fields.submissionError(window.I18n.t('submission.error', I18nScope({ message: errorMsg })));
    m.redraw();
    h.captureException(exception);
};

const paymentInfo = paymentId => commonPaymentInfo
    .postWithToken({ id: paymentId }, null, (h.isDevEnv() ? { 'X-forwarded-For': '127.0.0.1' } : {}))
    .catch((error) => {
        h.captureException(error);
        throw error;
    });

const creditCardInfo = creditCard => commonCreditCards
    .getRowWithToken(h.idVM.id(creditCard.id).parameters())
    .catch((error) => {
        h.captureException(error);
        throw error;
    });

let retries = 10;
const isReactivation = () => {
    const subscriptionStatus = m.route.param('subscription_status');
    return subscriptionStatus === 'inactive' || subscriptionStatus === 'canceled';
};
const resolvePayment = (gateway_payment_method, payment_confirmed, payment_id, isEdit) => m.route.set(`/projects/${projectVM.currentProject().project_id}/subscriptions/thank_you?project_id=${projectVM.currentProject().project_id}&payment_method=${gateway_payment_method}&payment_confirmed=${payment_confirmed}${payment_id ? `&payment_id=${payment_id}` : ''}${isEdit && !isReactivation() ? '&is_edit=1' : ''}`);
const requestInfo = (promise, paymentId, defaultPaymentMethod, isEdit) => {
    if (retries <= 0) {
        return promise.resolve(resolvePayment(defaultPaymentMethod, false, paymentId, isEdit));
    }

    paymentInfo(paymentId).then((infoR) => {
        if (_.isNull(infoR.gateway_payment_method) || _.isUndefined(infoR.gateway_payment_method)) {
            if (!_.isNull(infoR.gateway_errors)) {
                return promise.reject(_.first(infoR.gateway_errors));
            }

            return h.sleep(4000).then(() => {
                retries -= 1;

                return requestInfo(promise, paymentId, defaultPaymentMethod);
            });
        }

        return promise.resolve(resolvePayment(infoR.gateway_payment_method, true, paymentId, isEdit));
    }).catch(error => promise.reject({}));
};

const getPaymentInfoUntilNoError = (paymentMethod, isEdit) => ({ id, catalog_payment_id }) => {
    const p = new Promise((resolve, reject) => {
        const paymentId = isEdit ? catalog_payment_id : id;

        if (paymentId) {
            paymentInfoId(paymentId);
            requestInfo({resolve, reject}, paymentId, paymentMethod, isEdit);
        } else {
            resolvePayment(paymentMethod, false, null, isEdit);
        }
    });

    return p;
};


let creditCardRetries = 5;
const waitForSavedCreditCard = promise => (creditCardId) => {
    if (creditCardRetries <= 0) {
        return promise.reject({ message: 'Could not save card' });
    }

    creditCardInfo(creditCardId).then(([infoR]) => {
        if (_.isEmpty(infoR.gateway_data)) {
            if (!_.isEmpty(infoR.gateway_errors)) {
                return promise.reject(_.first(infoR.gateway_errors));
            }

            return h.sleep(4000).then(() => {
                creditCardRetries -= 1;

                return waitForSavedCreditCard(promise)(creditCardId);
            });
        }

        return promise.resolve({ creditCardId });
    }).catch(error => promise.reject({ message: error.message }));


    return promise;
};

const processCreditCard = (cardHash, fields) => {
    const p = new Promise((resolve, reject) => {
        saveCreditCard(cardHash)
            .then(waitForSavedCreditCard({resolve, reject}))
            .catch(reject);
    });

    return p;
};

const kondutoExecute = function () {
    const customerID = h.getUserCommonID();

    if (customerID) {
        var period = 300;
        var limit = 20 * 1e3;
        var nTry = 0;
        var intervalID = setInterval(function () {
            var clear = limit / period <= ++nTry;
            if ((typeof (Konduto) !== "undefined") && (typeof (Konduto.setCustomerID) !== "undefined")) {
                window.Konduto.setCustomerID(customerID);
                clear = true;
            }
            if (clear) {
                clearInterval(intervalID);
            }
        }, period);
    }
};

const sendCreditCardPayment = (selectedCreditCard, fields, commonData, addVM) => {

    if (!fields) {
        return false;
    }
    fields.isLoading(true);
    m.redraw();

    const meta = _.first(document.querySelectorAll('[name=pagarme-encryption-key]'));
    const encryptionKey = meta.getAttribute('content');

    window.pagarme.encryption_key = encryptionKey;
    const card = h.buildCreditCard(fields.creditCardFields);

    const customer = fields.fields;
    const address = customer.address().getFields();
    const phoneDdd = address.phone_number ? h.extractPhoneDDD(address.phone_number) : null;
    const phoneNumber = address.phone_number ? h.extractPhoneNumber(address.phone_number) : null;
    const addressState = address.state_id ? _.findWhere(addVM.states(), { id: address.state_id }) : address.address_state;
    const addressCountry = _.findWhere(addVM.countries(), { id: address.country_id }) || {};

    window.pagarme.client.connect({ encryption_key: encryptionKey })
        .then(client => client.security.encrypt(card))
        .then((cardHash) => {
            const payload = {
                subscription: true,
                anonymous: customer.anonymous(),
                user_id: commonData.userCommonId,
                project_id: commonData.projectCommonId,
                amount: commonData.amount,
                payment_method: 'credit_card',
                credit_card_owner_document: fields.creditCardFields.cardOwnerDocument(),
                is_international: address.country_id !== addVM.defaultCountryID,
                customer: {
                    name: customer.completeName(),
                    document_number: customer.ownerDocument(),
                    address: {
                        neighborhood: address.address_neighbourhood,
                        street: address.address_street,
                        street_number: address.address_number,
                        zipcode: address.address_zip_code,
                        country: addressCountry.name,
                        country_code: addressCountry.code,
                        state: addressState.acronym ? addressState.acronym : addressState,
                        city: address.address_city,
                        complementary: address.address_complement
                    },
                    phone: {
                        ddi: '55',
                        ddd: phoneDdd,
                        number: phoneNumber
                    }
                }
            };

            if (commonData.rewardCommonId) {
                _.extend(payload, { reward_id: commonData.rewardCommonId });
            }

            if (commonData.subscription_id) {
                _.extend(payload, { id: commonData.subscription_id });
            }

            const pay = ({ creditCardId }) => {
                kondutoExecute()
                const p = new Promise((resolve, reject) => {
                    if (creditCardId) {
                        _.extend(payload, {
                            card_id: creditCardId.id,
                            credit_card_id: creditCardId.id
                        });
                    }

                    if (commonData.subscription_id) {
                        sendSubscriptionUpgrade(payload).then(resolve).catch(reject);
                    } else {
                        sendPaymentRequest(payload).then(resolve).catch(reject);
                    }
                });

                return p;
            };

            updateUser(userPayload(customer, address))
                .then(() => processCreditCard(cardHash, fields))
                .then(pay)
                .then(getPaymentInfoUntilNoError(payload.payment_method, Boolean(commonData.subscription_id)))
                .catch(displayError(fields));

        });
};

const sendSlipPayment = (fields, commonData) => {
    fields.isLoading(true);
    m.redraw();

    const customer = fields.fields;
    const address = customer.address().getFields();
    const phoneDdd = address.phone_number ? h.extractPhoneDDD(address.phone_number) : null;
    const phoneNumber = address.phone_number ? h.extractPhoneNumber(address.phone_number) : null;
    const addressState = _.findWhere(addressVM.states(), { id: address.state_id });
    const addressCountry = _.findWhere(addressVM.countries(), { id: address.country_id });
    const payload = {
        subscription: true,
        anonymous: customer.anonymous(),
        user_id: commonData.userCommonId,
        project_id: commonData.projectCommonId,
        amount: commonData.amount,
        payment_method: 'boleto',
        customer: {
            name: customer.completeName(),
            document_number: customer.ownerDocument(),
            address: {
                neighborhood: address.address_neighbourhood,
                street: address.address_street,
                street_number: address.address_number,
                zipcode: address.address_zip_code,
                // TOdO: remove hard-coded country when international support is added on the back-end
                country: 'Brasil',
                country_code: 'BR',
                state: addressState.acronym,
                city: address.address_city,
                complementary: address.address_complement
            },
            phone: {
                ddi: '55',
                ddd: phoneDdd,
                number: phoneNumber
            }
        }
    };

    if (commonData.rewardCommonId) {
        _.extend(payload, { reward_id: commonData.rewardCommonId });
    }

    if (commonData.subscription_id) {
        _.extend(payload, { id: commonData.subscription_id });
    }

    const sendPayment = () => {
        const p = new Promise((resolve, reject) => {
            if (commonData.subscription_id) {
                sendSubscriptionUpgrade(payload).then(resolve).catch(reject);
            } else {
                sendPaymentRequest(payload).then(resolve).catch(reject);
            }
        });

        return p;
    };

    updateUser(userPayload(customer, address))
        .then(sendPayment)
        .then(getPaymentInfoUntilNoError(payload.payment_method, Boolean(commonData.subscription_id)))
        .catch(displayError(fields));
};

// Makes a request count down of retries of getting payment info
const trialsToGetPaymentInfo = (p, catalog_payment_id, retries) => {
    if (retries > 0) {
        paymentInfo(catalog_payment_id).then((infoR) => {
            if (_.isNull(infoR.gateway_payment_method) || _.isUndefined(infoR.gateway_payment_method)) {
                if (!_.isNull(infoR.gateway_errors)) {
                    return p.reject(_.first(infoR.gateway_errors));
                }

                return h.sleep(4000).then(() => trialsToGetPaymentInfo(p, catalog_payment_id, retries - 1));
            }

            return p.resolve({
                boleto_url: infoR.boleto_url,
                boleto_expiration_date: infoR.boleto_expiration_date,
                boleto_barcode: infoR.boleto_barcode,
                status: infoR.status
            });
        }).catch(() => p.reject({}));
    } else {
        return p.reject({});
    }

    return p.promise;
};

// Try recharge a payment if it's slip is expired, pinging /rpc/payment_info endpoint
// looking up for new payment_info
const tryRechargeSubscription = (subscription_id) => {
    const p = new Promise((resolve, reject) => {
        rechargeSubscription
            .postWithToken({ subscription_id })
            .then(payment_data => trialsToGetPaymentInfo({resolve, reject}, payment_data.catalog_payment_id, 5))
            .catch((error) => {
                h.captureException(error);
                throw error;
            })
            .catch(reject);
    });

    return p;
};

const commonPaymentVM = {
    sendCreditCardPayment,
    sendSlipPayment,
    paymentInfo,
    tryRechargeSubscription
};

export default commonPaymentVM;
