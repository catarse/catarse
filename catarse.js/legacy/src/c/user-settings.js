import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import userVM from '../vms/user-vm';
import h from '../h';
import popNotification from './pop-notification';
import projectEditSaveBtn from './project-edit-save-btn';
import userSettingsVM from '../vms/user-settings-vm';
import railsErrorsVM from '../vms/rails-errors-vm';

import userSettingsResponsible from './user-settings-responsible';
import userSettingsAddress from './user-settings-address';
import userSettingsSavedCreditCards from './user-settings-saved-credit-cards';
import userSettingsHelp from './user-settings-help';
import addressVM from '../vms/address-vm';

const I18nScope = _.partial(h.i18nScope, 'users.edit.settings_tab');

const userSettings = {
    oninit: function(vnode) {
        let parsedErrors = userSettingsVM.mapRailsErrors(railsErrorsVM.railsErrors());
        let deleteFormSubmit;
        const user = vnode.attrs.user();
        const userAddress = user.address || {};
        const addVM = prop(addressVM({ data: userAddress }));
        const fields = prop({
            owner_document: prop(user.owner_document || ''),
            name: prop(user.name || ''),
            state_inscription: prop(user.state_inscription || ''),
            address: prop(user.address || {}),
            birth_date: prop((user.birth_date ? h.momentify(user.birth_date) : '')),
            account_type: prop(user.account_type || '')
        });
        const loading = prop(false);
        const user_id = vnode.attrs.userId;
        const error = prop('');
        const loader = prop(true);
        const showSuccess = h.toggleProp(false, true);
        const showError = h.toggleProp(false, true);
        const documentMask = _.partial(h.mask, '999.999.999-99');
        const documentCompanyMask = _.partial(h.mask, '99.999.999/9999-99');
        const birthDayMask = _.partial(h.mask, '99/99/9999');
        const creditCards = prop();
        const toDeleteCard = prop(-1);
        const requestRedraw = () => {
                m.redraw();
            },
            deleteCard = id => () => {
                toDeleteCard(id);
                // We must redraw here to update the action output of the hidden form on the DOM.
                requestRedraw();
                deleteFormSubmit();
                return false;
            },
            setCardDeletionForm = (localVnode) => {
                deleteFormSubmit = () => localVnode.dom.submit();
            },
            updateUserData = () => {
                const userData = {
                    cpf: fields().owner_document(),
                    name: fields().name(),
                    address_attributes: addVM().getFields(),
                    account_type: fields().account_type(),
                    birth_date: fields().birth_date(),
                    state_inscription: fields().state_inscription
                };

                if (vnode.attrs.publishingUserSettings) {
                    userData.publishing_user_settings = true;
                }

                return m.request({
                    method: 'PUT',
                    url: `/users/${user_id}.json`,
                    data: {
                        user: userData
                    },
                    config: h.setCsrfToken
                }).then(() => {
                    if (parsedErrors) {
                        parsedErrors.resetFieldErrors();
                    }
                    loading(false);
                    if (!showSuccess()) {
                        showSuccess.toggle();
                    }
                    railsErrorsVM.validatePublish();
                    requestRedraw();
                }).catch((err) => {
                    if (parsedErrors) {
                        parsedErrors.resetFieldErrors();
                    }
                    parsedErrors = userSettingsVM.mapRailsErrors(err.errors_json);
                    error('Erro ao atualizar informações.');
                    loading(false);
                    if (showSuccess()) {
                        showSuccess.toggle();
                    }
                    if (!showError()) {
                        showError.toggle();
                    }
                    requestRedraw();
                });
            },
            onSubmit = () => {
                loading(true);
                requestRedraw();
                updateUserData();
                return false;
            },
            applyBirthDateMask = _.compose(fields().birth_date, birthDayMask),
            applyDocumentMask = (value) => {
                if (fields().account_type() != 'pf') {
                    fields().owner_document(documentCompanyMask(value));
                } else {
                    fields().owner_document(documentMask(value));
                }
                requestRedraw();
            },
            handleError = () => {
                error(true);
                loader(false);
                requestRedraw();
            };

        userVM.getUserCreditCards(vnode.attrs.userId).then(creditCards).catch(handleError);
        if (parsedErrors.hasError('country_id')) {
            parsedErrors.inlineError('country_id', false);
        }

        vnode.attrs.user.map((userData) => {
            fields().owner_document(userData.owner_document || '');
            fields().name(userData.name || '');
            fields().state_inscription(userData.state_inscription || '');
            fields().address(userData.address || {});
            fields().birth_date((userData.birth_date ? h.momentify(userData.birth_date) : ''));
            fields().account_type(userData.account_type || '');
            addVM().setFields(userData.address || {});
        });

        vnode.state = {
            handleError,
            applyDocumentMask,
            fields,
            loader,
            showSuccess,
            showError,
            onSubmit,
            error,
            creditCards,
            deleteCard,
            toDeleteCard,
            setCardDeletionForm,
            applyBirthDateMask,
            loading,
            parsedErrors,
            addVM
        };
    },
    view: function({state, attrs}) {
        
        const user = attrs.user();
        const fields = state.fields;
        const addVM = state.addVM;
        const hasContributedOrPublished = (user.total_contributed_projects >= 1 || user.total_published_projects >= 1);
        const disableFields = (user.is_admin_role ? false : (hasContributedOrPublished && !_.isEmpty(user.name) && !_.isEmpty(user.owner_document)));
        const applyBirthDateMask = state.applyBirthDateMask;
        const applyDocumentMask = state.applyDocumentMask;
        const parsedErrors = state.parsedErrors;
        const creditCards = state.creditCards;
        const toDeleteCard = state.toDeleteCard;
        const deleteCard = state.deleteCard;
        const setCardDeletionForm = state.setCardDeletionForm;
        const shouldHideCreditCards = attrs.hideCreditCards;
        const isProjectUserEdit = !!attrs.isProjectUserEdit;

        return m('[id=\'settings-tab\']', [
            (
                state.showSuccess() ? 
                    m(popNotification, {
                        message: window.I18n.t('update_success_msg', I18nScope()),
                        toggleOpt: state.showSuccess
                    }) 
                : 
                ''
            ),
            (
                state.showError() ? 
                    m(popNotification, {
                        message: state.error(),
                        toggleOpt: state.showError,
                        error: true
                    }) 
                : 
                    ''
            ),
            m('form.w-form', { onsubmit: state.onSubmit }, [
                m('div', [
                    m('.w-container',
                        (
                            isProjectUserEdit ? 
                                m('.w-row', [
                                    m(".w-col.w-col-8", [
                                        m(userSettingsResponsible, { parsedErrors, fields, user, disableFields, applyDocumentMask, applyBirthDateMask }),
                                        m(userSettingsAddress, { addVM, parsedErrors })
                                    ]),
                                    m(userSettingsHelp, {})
                                ])
                            : 
                                m('.w-col.w-col-10.w-col-push-1', [
                                    m(userSettingsResponsible, { parsedErrors, fields, user, disableFields, applyDocumentMask, applyBirthDateMask }),
                                    m(userSettingsAddress, { addVM, parsedErrors }),
                                    (shouldHideCreditCards ? '' : m(userSettingsSavedCreditCards, { user, creditCards, setCardDeletionForm, deleteCard, toDeleteCard }))
                                ])
                        )
                    ),
                    m(projectEditSaveBtn, {
                        loading: state.loading,
                        onSubmit: state.onSubmit
                    })
                ])
            ])
        ]);
    }
};

export default userSettings;
