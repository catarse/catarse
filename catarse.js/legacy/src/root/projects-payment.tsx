import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import contributionVM from '../vms/contribution-vm';
import rewardVM from '../vms/reward-vm';
import paymentVM from '../vms/payment-vm';
import projectVM from '../vms/project-vm';
import addressVM from '../vms/address-vm';
import usersVM from '../vms/user-vm';
import FaqBox from '../c/faq-box';
import nationalityRadio from '../c/nationality-radio';
import PaymentForm from '../c/payment-form';
import inlineError from '../c/inline-error';
import AddressForm from '../c/address-form';
import { catarse } from '../api';
import models from '../models';
import { ProjectsPaymentUserDetails } from '../c/projects-payment-user-details';
import { ThisWindow, CatarseAnalyticsType, ProjectDetails, RewardDetails } from '../entities';
import { I18nText } from '../shared/components/i18n-text';
import { If } from '../shared/components/if';
import { CurrencyFormat } from '../shared/components/currency-format';
import { useState, withHooks } from 'mithril-hooks';
import { DateFormat } from '../shared/components/date-format';
import { ProjectsPaymentRewardDetails } from '../c/projects-payment-reward-detail'
import { Loader } from '../shared/components/loader';

declare var window : ThisWindow
declare var CatarseAnalytics : CatarseAnalyticsType

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit');
const I18nIntScope = _.partial(h.i18nScope, 'projects.contributions.edit_international');

export default class ProjectsPayment {
    oninit(vnode) {

        const {
            ViewContentEvent,
            AddToCartEvent
        } = projectVM;

        projectVM.sendPageViewForCurrentProject(null, [ ViewContentEvent(), AddToCartEvent() ]);

        const project = projectVM.currentProject;
        const vm = paymentVM();
        const showPaymentForm = prop(false);
        const contribution = contributionVM.getCurrentContribution();
        const reward = prop(contribution?.reward);
        const value = contribution.value;
        const documentMask = _.partial(h.mask, '999.999.999-99');
        const documentCompanyMask = _.partial(h.mask, '99.999.999/9999-99');
        const isCnpj = prop(false);
        const currentUserID = h.getUserID();
        const countriesLoader = catarse.loader(models.country.getPageOptions());
        const user = usersVM.getCurrentUser();

        vm.fields.address().setFields(vnode.attrs.address || vm.fields.address());

        const shippingFee = () =>
            _.findWhere(rewardVM.fees(), {
                id: contribution.shipping_fee_id,
            });

        const validateForm = () => {
            if (vm.validate()) {
                vm.kondutoExecute();
                showPaymentForm(true);
            } else {
                h.scrollTop();
            }
            h.redraw();
        };

        const fieldErrors = (fieldName : string): string[] => {
            const fieldWithError = _.findWhere(vm.fields.errors(), { field: fieldName })
            return fieldWithError?.message ? [fieldWithError?.message] : []
        }

        const fieldHasError = (fieldName : string): boolean => {
            const fieldWithError = _.findWhere(vm.fields.errors(), { field: fieldName });
            return !!fieldWithError;
        };

        const applyDocumentMask = value => {
            if (value.length > 14) {
                isCnpj(true);
                vm.fields.ownerDocument(documentCompanyMask(value));
            } else {
                isCnpj(false);
                vm.fields.ownerDocument(documentMask(value));
            }

            return vm.fields.ownerDocument();
        };

        const addressChange = fn => e => {
            CatarseAnalytics.oneTimeEvent({
                cat: 'contribution_finish',
                act: vm.isInternational ? 'contribution_address_br' : 'contribution_address_int',
            });

            if (_.isFunction(fn)) {
                fn(e);
            }
        };

        const scope = attr => (vm.isInternational() ? I18nIntScope(attr) : I18nScope(attr));

        const isLongDescription = reward => reward.description && reward.description.length > 110;

        if (_.isNull(currentUserID)) {
            return h.navigateToDevise();
        }
        if (reward() && !_.isNull(reward().id)) {
            rewardVM
                .getFees(reward())
                .then(fees => {
                    rewardVM.fees(fees);
                    h.redraw();
                })
                .catch(err => m.redraw());
        }

        vm.fetchUser().then(() => {
            countriesLoader
                .load()
                .then((countryData) => {
                    vm.fields.address().countries(_.sortBy(countryData, 'name_en'));
                    h.redraw();
                });
            h.redraw();
        });

        vm.kondutoExecute();
        projectVM.getCurrentProject();

        vnode.state.addressChange = addressChange;
        vnode.state.applyDocumentMask = applyDocumentMask;
        vnode.state.fieldHasError = fieldHasError;
        vnode.state.validateForm = validateForm;
        vnode.state.showPaymentForm = showPaymentForm;
        vnode.state.contribution = contribution;
        vnode.state.reward = reward;
        vnode.state.value = value;
        vnode.state.scope = scope;
        vnode.state.isCnpj = isCnpj;
        vnode.state.vm = vm;
        vnode.state.user = user;
        vnode.state.project = project;
        vnode.state.shippingFee = shippingFee;
        vnode.state.isLongDescription = isLongDescription;
        vnode.state.toggleDescription = h.toggleProp(false, true);
        vnode.state.fieldErrors = fieldErrors;
    }

    view({ state }) {
        try {
            const user = state.user();
            const project = state.project();
            const reward = state.reward();
            const address = state.vm.fields.address();
            const anonymous = state.vm.fields.anonymous();
            const anonymousToggle = state.vm.fields.anonymous.toggle;
            const isInternational = state.vm.isInternational()
            const value = state.value;
            const hasProjectAndUserAddressLoaded = !!address && !!project;
            const scope = isInternational ? 'projects.contributions.edit_international' : 'projects.contributions.edit'
            const onclickNextStep = () => {
                CatarseAnalytics.event(
                    {
                        cat: 'contribution_finish',
                        act: 'contribution_next_click',
                    },
                    state.validateForm
                )
            }

            if (hasProjectAndUserAddressLoaded) {
                return (
                    <div id="project-payment" class="w-section w-clearfix section">
                        <div class="w-col">
                            <div class="w-clearfix w-hidden-main w-hidden-medium card u-radius u-marginbottom-20">
                                <ProjectsPaymentRewardDetails
                                    isInternational={isInternational}
                                    project={project}
                                    reward={reward}
                                    value={value}
                                />
                            </div>
                        </div>
                        <div class="w-container">
                            <div class="w-row">
                                <div class="w-col w-col-8">
                                    <div class="w-form">
                                        <form class="u-marginbottom-40">
                                            <div class="u-marginbottom-40 u-text-center-small-only">
                                                <div class="fontweight-semibold lineheight-tight fontsize-large">
                                                    <I18nText scope={`${scope}.title`} />
                                                </div>
                                                <div class="fontsize-smaller">
                                                    <I18nText scope={`${scope}.required`} />
                                                </div>
                                            </div>

                                            <ProjectsPaymentUserDetails
                                                user={user}
                                                reward={reward}
                                                project={project}
                                                value={state.value}
                                                isAnonymous={anonymous}
                                                anonymousToggle={anonymousToggle}
                                                isInternational={state.vm.isInternational()}
                                                getErrors={(field : string) => state.fieldErrors(field)}
                                                hasError={(field : string) => state.fieldHasError(field)}
                                                onChangeFullName={(newFullName : string) => state.vm.fields.completeName(newFullName)}
                                                fullName={state.vm.fields.completeName()}
                                                onChangeOwnerDocument={(newOwnerDocument : string) => state.vm.fields.ownerDocument(newOwnerDocument)}
                                                ownerDocument={state.vm.fields.ownerDocument()}
                                                documentMask={(newInputValue : string) => state.applyDocumentMask(newInputValue)}
                                            />

                                            <div class="card card-terciary u-radius u-marginbottom-40">
                                                <AddressForm
                                                    addVM={address}
                                                    addressFields={address.fields}
                                                    international={state.vm.isInternational}
                                                    hideNationality={true}
                                                />
                                            </div>
                                        </form>
                                    </div>

                                    <div class="w-row u-marginbottom-40">
                                        <If condition={!state.showPaymentForm()}>
                                            <div class="w-col w-col-push-3 w-col-6">
                                                <button onclick={onclickNextStep} class="btn btn-large">
                                                    <I18nText scope={`${scope}.next_step`} />
                                                </button>
                                            </div>
                                        </If>
                                    </div>

                                    <If condition={state.showPaymentForm()}>
                                        <PaymentForm
                                            vm={state.vm}
                                            contribution_id={state.contribution.id}
                                            project_id={project.project_id}
                                            user_id={user.id}
                                        />
                                    </If>
                                </div>

                                <div class="w-col w-col-4">
                                    <div class="card u-marginbottom-20 u-radius w-hidden-small w-hidden-tiny">
                                        <ProjectsPaymentRewardDetails
                                            isInternational={isInternational}
                                            project={project}
                                            reward={reward}
                                            value={value}
                                        />
                                    </div>
                                    <FaqBox
                                        mode={project.mode}
                                        vm={state.vm}
                                        faq={state.vm.faq(project.mode)}
                                        projectUserId={project.user_id}
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                )
            } else {
                return <Loader />
            }
        } catch(error) {
            console.log('Error on projects-payment.js', error);
            return <div />;
        }
    }
}
