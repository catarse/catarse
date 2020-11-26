import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import tooltip from './tooltip';
import creditCardVM from '../vms/credit-card-vm';
import projectVM from '../vms/project-vm';
import creditCardInput from './credit-card-input';
import inlineError from './inline-error';
import subscriptionEditModal from './subscription-edit-modal';
import commonPaymentVM from '../vms/common-payment-vm';

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit');
const I18nIntScope = _.partial(h.i18nScope, 'projects.contributions.edit_international');

const paymentCreditCard = {
    oninit: function(vnode) {
        const vm = vnode.attrs.vm,
            isSubscriptionEdit = vnode.attrs.isSubscriptionEdit || prop(false),
            subscriptionEditConfirmed = prop(false),
            showSubscriptionModal = prop(false),
            loadingInstallments = prop(true),
            loadingSavedCreditCards = prop(true),
            selectedCreditCard = prop({ id: -1 }),
            selectedInstallment = prop('1'),
            showForm = prop(false),
            creditCardType = prop('unknown'),
            documentMask = _.partial(h.mask, '999.999.999-99'),
            documentCompanyMask = _.partial(h.mask, '99.999.999/9999-99');

        const sendSubscriptionPayment = (creditCard, subscriptionVM, commonData) => {
            if (!isSubscriptionEdit()) {
                commonPaymentVM.sendCreditCardPayment(creditCard, subscriptionVM, commonData, vnode.attrs.addressVM);

                return false;
            }

            if (!subscriptionEditConfirmed() && !vnode.attrs.isReactivation()) {
                showSubscriptionModal(true);

                return false;
            }

            const data = _.extend({}, commonData, { subscription_id: vnode.attrs.subscriptionId() });

            commonPaymentVM.sendCreditCardPayment(
                selectedCreditCard,
                subscriptionVM,
                data,
                vnode.attrs.addressVM
            );

            return false;
        };

        const handleValidity = (isValid, errorObj) => {
            if (!isValid) {
                vm.creditCardFields.errors().push(errorObj);
            } else {
                const errorsWithout = _.reject(vm.creditCardFields.errors(), err => _.isEqual(err, errorObj));
                vm.creditCardFields.errors(errorsWithout);
            }
        };

        const checkcvv = () => {
            const isValid = creditCardVM.validateCardcvv(vm.creditCardFields.cvv(), creditCardType()),
                errorObj = { field: 'cvv', message: window.I18n.t('errors.inline.creditcard_cvv', scope()) };

            handleValidity(isValid, errorObj);
        };

        const checkExpiry = () => {
            const isValid = creditCardVM.validateCardExpiry(vm.creditCardFields.expMonth(), vm.creditCardFields.expYear()),
                errorObj = { field: 'expiry', message: window.I18n.t('errors.inline.creditcard_expiry', scope()) };

            handleValidity(isValid, errorObj);
        };

        const checkCreditCard = () => {
            const isValid = creditCardVM.validateCardNumber(vm.creditCardFields.number()),
                errorObj = { field: 'number', message: window.I18n.t('errors.inline.creditcard_number', scope()) };

            handleValidity(isValid, errorObj);
        };

        const checkCardOwnerDocument = () => {
            const document = vm.creditCardFields.cardOwnerDocument(),
                striped = String(document).replace(/[\.|\-|\/]*/g, '');
            let isValid = false,
                errorMessage = '';

            if (document.length > 14) {
                isValid = h.validateCnpj(document);
                errorMessage = 'CNPJ inválido.';
            } else {
                isValid = h.validateCpf(striped);
                errorMessage = 'CPF inválido.';
            }

            handleValidity(isValid, { field: 'cardOwnerDocument', message: errorMessage });
        };

        const checkCreditCardName = () => {
            const trimmedString = vm.creditCardFields.name().replace(/ /g, '');
            const charsOnly = /^[a-zA-ZàèìòùÀÈÌÒÙáéíóúýÁÉÍÓÚÝâêîôûÂÊÎÔÛãñõÃÑÕäëïöüÿÄËÏÖÜŸçÇßØøÅåÆæœ]*$/;
            const errorObj = { field: 'name', message: window.I18n.t('errors.inline.creditcard_name', scope()) };
            const isValid = !(_.isEmpty(trimmedString) || !charsOnly.test(trimmedString));

            handleValidity(isValid, errorObj);
        };
        const onSubmit = () => {
            vm.creditCardFields.errors([]);

            if (selectedCreditCard().id === -1) {
                if (!vm.isInternational()) {
                    checkCardOwnerDocument();
                }
                checkExpiry();
                checkcvv();
                checkCreditCard();
                checkCreditCardName();
            }

            if (vm.creditCardFields.errors().length === 0) {
                if (vnode.attrs.isSubscription) {
                    const commonData = {
                        rewardCommonId: vnode.attrs.reward_common_id,
                        userCommonId: vnode.attrs.user_common_id,
                        projectCommonId: vnode.attrs.project_common_id,
                        amount: vnode.attrs.value * 100
                    };
                    sendSubscriptionPayment(selectedCreditCard, vm, commonData);
                } else {
                    vm.sendPayment(selectedCreditCard, selectedInstallment, vnode.attrs.contribution_id, vnode.attrs.project_id);
                }
            }

            return false;
        };

        const applyCreditCardNameMask = _.compose(vm.creditCardFields.name, h.noNumbersMask);

        const applyCvvMask = (value) => {
            const setValue = h.numbersOnlyMask(value.substr(0, 4));

            return vm.creditCardFields.cvv(setValue);
        };

        const applyDocumentMask = (value) => {
            if (value.length > 14) {
                vm.creditCardFields.cardOwnerDocument(documentCompanyMask(value));
            } else {
                vm.creditCardFields.cardOwnerDocument(documentMask(value));
            }
        };


        const fieldHasError = (fieldName) => {
            const fieldWithError = _.findWhere(vm.creditCardFields.errors(), { field: fieldName });

            return fieldWithError ? m(inlineError, { message: fieldWithError.message }) : '';
        };

        const buildTooltip = tooltipText => m(tooltip, {
            el: '.tooltip-wrapper.fa.fa-question-circle.fontcolor-secondary',
            text: tooltipText,
            width: 380
        });

        const isCreditCardSelected = (card, idx) => selectedCreditCard() === card;

        const loadPagarme = (vnode) => {
            const script = document.createElement('script');
            script.src = '//assets.pagar.me/pagarme-js/4.8/pagarme.min.js';
            document.body.appendChild(script);
            script.onload = () => {
                vm.pagarme(window.pagarme);
            };
        };

        const selectCreditCard = (card) => {
            selectedCreditCard(card);

            if (card.id === -1) {
                showForm(true);
            } else {
                showForm(false);
            }
        };

        const scope = attr => vm.isInternational()
                   ? I18nIntScope(attr)
                   : I18nScope(attr);

        // Sum the total amount of installments with taxes and returns a formated string
        const totalAmountOfInstallment = (installments, selectedIndex) => h.formatNumber(installments[selectedIndex - 1].total_amount, 2);

        if (!vnode.attrs.isSubscription) {
            vm.getInstallments(vnode.attrs.contribution_id)
                .then(() => {
                    loadingInstallments(false);
                    m.redraw();
                });
        }

        if (!vnode.attrs.hideSave) {
            vm.getSavedCreditCards(vnode.attrs.user_id)
                .then((savedCards) => {
                    loadingSavedCreditCards(false);
                    selectCreditCard(savedCards[0]);
                    m.redraw();
                });
        } else {
            showForm(true);
        }

        vnode.state = {
            vm,
            onSubmit,
            fieldHasError,
            buildTooltip,
            loadingInstallments,
            loadingSavedCreditCards,
            installments: vm.installments,
            selectedInstallment,
            savedCreditCards: vm.savedCreditCards,
            creditCard: vm.creditCardFields,
            creditCardType,
            checkCreditCard,
            checkCreditCardName,
            applyCreditCardNameMask,
            applyCreditCardMask: vm.applyCreditCardMask,
            applyDocumentMask,
            checkCardOwnerDocument,
            applyCvvMask,
            checkcvv,
            selectCreditCard,
            isCreditCardSelected,
            expMonths: vm.expMonthOptions(),
            expYears: vm.expYearOptions(),
            loadPagarme,
            scope,
            totalAmountOfInstallment,
            showForm,
            showSubscriptionModal,
            sendSubscriptionPayment,
            subscriptionEditConfirmed,
            isSubscriptionEdit
        };
    },
    view: function({state, attrs}) {
        const isInternational = state.vm.isInternational();

        return m('.w-form.u-marginbottom-40', {
            oncreate: state.loadPagarme
        }, [
            m('form[method="post"][name="email-form"]', {
                onsubmit: state.onSubmit
            }, [
                (!attrs.hideSave && !state.loadingSavedCreditCards() && (state.savedCreditCards().length > 1)) ?

                    m('.my-credit-cards.w-form.back-payment-form-creditcard.records-choice.u-marginbottom-40',
                        _.map(state.savedCreditCards(), (card, idx) => m(`div#credit-card-record-${idx}.creditcard-records`, {
                            style: 'cursor:pointer;',
                            onclick: () => state.selectCreditCard(card)
                        }, [
                            m('.w-row', [
                                m('.w-col.w-col-1',
                                    m('.back-payment-credit-card-radio-field.w-clearfix.w-radio', [
                                        m('input', {
                                            checked: state.isCreditCardSelected(card, idx),
                                            name: 'payment_subscription_card',
                                            type: 'radio',
                                            value: card.card_key
                                        })
                                    ])
                                ),
                                card.id === -1 ?
                                m('.w-col.w-col-11',
                                    m('.fontsize-small.fontweight-semibold.fontcolor-secondary', window.I18n.t('credit_card.use_another', state.scope()))
                                ) : [
                                    m('.w-col.w-col-2',
                                        m('.fontsize-small.fontweight-semibold.text-success', card.card_brand.toUpperCase())
                                    ),
                                    m('.w-col.w-col-5',
                                        m('.fontsize-small.fontweight-semibold.u-marginbottom-20', `XXXX.XXXX.XXXX.${card.last_digits}`)
                                    ),
                                    m('.w-clearfix.w-col.w-col-4', [
                                        (state.loadingInstallments() || (state.installments().length <= 1)) ? '' :
                                            m('select.w-select.text-field.text-field-creditcard', {
                                                onchange: m.withAttr('value', state.selectedInstallment),
                                                value: state.selectedInstallment()
                                            }, _.map(state.installments(), installment => m('option', { value: installment.number },
                                                `${installment.number} X R$ ${ h.formatNumber(installment.amount, 2) } ${window.I18n.t(`credit_card.installments_number.${installment.number}`, state.scope())}`
                                            ))
                                        ),
                                        (
						                state.selectedInstallment() > 1 ?
                                            	m('.fontsize-small.lineheight-looser.fontweight-semibold.fontcolor-secondary', [
                                                	window.I18n.t('credit_card.total', state.scope()), `R$ ${state.totalAmountOfInstallment(state.installments(), state.selectedInstallment())}`
                                            	])
                                        	: ''
					                    )
                                    ])
                                ]
                            ])
                        ])
                    )
                )
                : !attrs.hideSave && state.loadingSavedCreditCards() ? m('.fontsize-small.u-marginbottom-40', window.I18n.t('credit_card.loading', state.scope())) : '',
                !state.showForm() ? '' : m('#credit-card-payment-form.u-marginbottom-40', [
                    m('div#credit-card-name', [
                        m('.w-row', [
                            m((isInternational ? '.w-col.w-col-12' : '.w-col.w-col-6.w-col-tiny-6.w-sub-col-middle'), [
                                m('label.field-label.fontweight-semibold[for="credit-card-name"]',
                                  window.I18n.t('credit_card.name', state.scope())
                                 ),
                                m('.fontsize-smallest.fontcolor-terciary.u-marginbottom-10.field-label-tip.u-marginbottom-10',
                                  window.I18n.t('credit_card.name_tip', state.scope())
                                 ),
                                m('input.w-input.text-field[name="credit-card-name"][type="text"]', {
                                    onfocus: state.vm.resetCreditCardFieldError('name'),
                                    class: state.fieldHasError('name') ? 'error' : '',
                                    onblur: state.checkCreditCardName,
                                    onkeyup: m.withAttr('value', state.applyCreditCardNameMask),
                                    value: state.creditCard.name()
                                }),
                                state.fieldHasError('name')
                            ]),
                            (!isInternational ?
                             m('.w-col.w-col-6.w-col-tiny-6.w-sub-col-middle', [
                                 m('label.field-label.fontweight-semibold[for="credit-card-document"]',
                                   window.I18n.t('credit_card.document', state.scope())
                                  ),
                                 m('.fontsize-smallest.fontcolor-terciary.u-marginbottom-10.field-label-tip.u-marginbottom-10',
                                   window.I18n.t('credit_card.document_tip', state.scope())
                                  ),
                                 m('input.w-input.text-field[name="credit-card-document"][id="credit-card-document"]', {
                                     onfocus: state.vm.resetCreditCardFieldError('cardOwnerDocument'),
                                     class: state.fieldHasError('cardOwnerDocument') ? 'error' : '',
                                     onblur: state.checkCardOwnerDocument,
                                     onkeyup: m.withAttr('value', state.applyDocumentMask),
                                     value: state.creditCard.cardOwnerDocument(),
                                     name: 'card-owner-document'
                                 }),
                                 state.fieldHasError('cardOwnerDocument')
                             ]) : '')
                        ]),
                    ]),
                    m('div#credit-card-number', [
                        m('label.field-label.fontweight-semibold[for="credit-card-number"]',
                            window.I18n.t('credit_card.number', state.scope())
                        ),
                        m('.fontsize-smallest.fontcolor-terciary.u-marginbottom-10.field-label-tip.u-marginbottom-10',
                            window.I18n.t('credit_card.number_tip', state.scope())
                        ),
                        m(creditCardInput, {
                            onfocus: state.vm.resetCreditCardFieldError('number'),
                            onblur: state.checkCreditCard,
                            class: state.fieldHasError('number') ? 'error' : '',
                            value: state.creditCard.number,
                            name: 'credit-card-number',
                            type: state.creditCardType
                        }),
                        state.fieldHasError('number')
                    ]),
                    m('div#credit-card-date', [
                        m('label.field-label.fontweight-semibold[for="expiration-date"]', [
                            window.I18n.t('credit_card.expiry', state.scope())
                        ]),
                        m('.fontsize-smallest.fontcolor-terciary.u-marginbottom-10.field-label-tip.u-marginbottom-10',
                            window.I18n.t('credit_card.expiry_tip', state.scope())
                        ),
                        m('.w-row', [
                            m('.w-col.w-col-6.w-col-tiny-6.w-sub-col-middle',
                                m('select.w-select.text-field[name="expiration-date_month"]', {
                                    onfocus: state.vm.resetCreditCardFieldError('expiry'),
                                    class: state.fieldHasError('expiry') ? 'error' : '',
                                    onchange: m.withAttr('value', state.creditCard.expMonth),
                                    value: state.creditCard.expMonth()
                                }, _.map(state.expMonths, month => m('option', { value: month[0] }, month[1])))
                            ),
                            m('.w-col.w-col-6.w-col-tiny-6',
                                m('select.w-select.text-field[name="expiration-date_year"]', {
                                    onfocus: state.vm.resetCreditCardFieldError('expiry'),
                                    class: state.fieldHasError('expiry') ? 'error' : '',
                                    onchange: m.withAttr('value', state.creditCard.expYear),
                                    onblur: state.checkExpiry,
                                    value: state.creditCard.expYear()
                                }, _.map(state.expYears, year => m('option', { value: year }, year)))
                            ),
                            m('.w-col.w-col-12', state.fieldHasError('expiry'))
                        ])
                    ]),
                    m('div#credit-card-cvv', [
                        m('label.field-label.fontweight-semibold[for="credit-card-cvv"]', [
                            window.I18n.t('credit_card.cvv', state.scope()),
                            state.buildTooltip(window.I18n.t('credit_card.cvv_tooltip', state.scope()))
                        ]),
                        m('.fontsize-smallest.fontcolor-terciary.u-marginbottom-10.field-label-tip.u-marginbottom-10',
                            window.I18n.t('credit_card.cvv_tip', state.scope())
                        ),
                        m('.w-row', [
                            m('.w-col.w-col-8.w-col-tiny-6.w-sub-col-middle',
                                m('input.w-input.text-field[name="credit-card-cvv"][type="tel"]', {
                                    onfocus: state.vm.resetCreditCardFieldError('cvv'),
                                    class: state.fieldHasError('cvv') ? 'error' : '',
                                    onkeyup: m.withAttr('value', state.applyCvvMask),
                                    onblur: state.checkcvv,
                                    value: state.creditCard.cvv()
                                }),
                                state.fieldHasError('cvv')
                            ),
                            m('.w-col.w-col-4.w-col-tiny-6.u-text-center',
                                m('img[src="https://daks2k3a4ib2z.cloudfront.net/54b440b85608e3f4389db387/57298c1c7e99926e77127bdd_cvv-card.jpg"][width="176"]')
                            )
                        ])
                    ]),
                    (
                        (projectVM.isSubscription() || (state.loadingInstallments() || (state.installments().length <= 1))) ? 
                            '' 
                        : 
                            m('.w-row', [
                                m('.w-clearfix.w-col.w-col-6', [
                                    m('label.field-label.fontweight-semibold[for="split"]',
                                        window.I18n.t('credit_card.installments', state.scope())
                                    ),
                                    m('select.text-field.text-field-creditcard.w-select[name="split"]', {
                                        onchange: m.withAttr('value', state.selectedInstallment),
                                        value: state.selectedInstallment()
                                    }, _.map(state.installments(), installment => m(`option[value="${installment.number}"]`,
                                            `${installment.number} X R$ ${ h.formatNumber(installment.amount, 2) } ${window.I18n.t(`credit_card.installments_number.${installment.number}`, state.scope())}`
                                    ))),
                                    (
                                        state.selectedInstallment() > 1 ?
                                            m('.fontsize-small.lineheight-looser.fontweight-semibold.fontcolor-secondary', [
                                                window.I18n.t('credit_card.total', state.scope()), `R$ ${state.totalAmountOfInstallment(state.installments(), state.selectedInstallment())}`
                                            ])
                                            : ''
                                    )
                                ]),
                                m('.w-col.w-col-6')
                            ])
                    ),
                    attrs.hideSave ? '' : m('.card.card-terciary.u-radius.u-margintop-30',
                        m('.fontsize-small.w-clearfix.w-checkbox', [
                            m('input#payment_save_card.w-checkbox-input[type="checkbox"][name="payment_save_card"]', {
                                onchange: m.withAttr('checked', state.creditCard.save),
                                checked: state.creditCard.save()
                            }),
                            m('label.w-form-label[for="payment_save_card"]',
                                window.I18n.t('credit_card.save_card', state.scope())
                            )
                        ])
                    )
                ]),
                m('.w-row', [
                    m('.w-col.w-col-8.w-col-push-2', [
                        (
                            !_.isEmpty(state.vm.submissionError()) ? 
                                (
                                    m('.card.card-error.u-radius.zindex-10.u-marginbottom-30.fontsize-smaller',
                                        m('.u-marginbottom-10.fontweight-bold', m.trust(state.vm.submissionError()))) 
                                )
                            : 
                                ''
                        ),
                        (
                            state.vm.isLoading() ? 
                                h.loader() 
                            : 
                                m('input.btn.btn-large.u-marginbottom-20[type="submit"]', { 
                                    value: (
                                        state.isSubscriptionEdit() && !attrs.isReactivation() ? 
                                            window.I18n.t('subscription_edit', state.scope())
                                        : 
                                            window.I18n.t('credit_card.finish_payment', state.scope())
                                    )
                                })
                        ),
                        m('.fontsize-smallest.u-text-center.u-marginbottom-30',
                            m.trust(
                                window.I18n.t('credit_card.terms_of_use_agreement', state.scope())
                            )
                        )
                    ])
                ]),
                state.showSubscriptionModal()
                    ? m(subscriptionEditModal,
                        {
                            attrs,
                            vm: state.vm,
                            showModal: state.showSubscriptionModal,
                            confirm: state.subscriptionEditConfirmed,
                            paymentMethod: 'credit_card',
                            pay: state.onSubmit
                        }
                    ) : null
            ])
        ]);
    }
};

export default paymentCreditCard;
