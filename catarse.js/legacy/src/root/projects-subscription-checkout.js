import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import moment from 'moment';
import { catarse } from '../api';
import models from '../models';
import h from '../h';
import contributionVM from '../vms/contribution-vm';
import rewardVM from '../vms/reward-vm';
import paymentVM from '../vms/payment-vm';
import projectVM from '../vms/project-vm';
import addressVM from '../vms/address-vm';
import usersVM from '../vms/user-vm';
import subscriptionVM from '../vms/subscription-vm';
import faqBox from '../c/faq-box';
import nationalityRadio from '../c/nationality-radio';
import paymentForm from '../c/payment-form';
import inlineError from '../c/inline-error';
import addressForm from '../c/address-form';

const { CatarseAnalytics } = window;

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit');
const I18nIntScope = _.partial(h.i18nScope, 'projects.contributions.edit_international');

const projectsSubscriptionCheckout = {
    oninit: function(vnode) {
        const {
            ViewContentEvent,
            AddToCartEvent
        } = projectVM;
        
        projectVM.sendPageViewForCurrentProject(null, [ ViewContentEvent(), AddToCartEvent() ]);
        projectVM.getCurrentProject();

        const project = projectVM.currentProject;
        const project_id = m.route.param('project_id');
        const vm = paymentVM();
        const showPaymentForm = prop(false);
        const documentMask = _.partial(h.mask, '999.999.999-99');
        const documentCompanyMask = _.partial(h.mask, '99.999.999/9999-99');
        const isCnpj = prop(false);
        const currentUserID = h.getUserID();
        const user = usersVM.getCurrentUser();
        const oldSubscription = prop({});
        const countriesLoader = catarse.loader(models.country.getPageOptions());
        const error = prop();

        const subscriptionId = prop(m.route.param('subscription_id'));
        const isEdit = prop(Boolean(subscriptionId()));
        const subscriptionStatus = m.route.param('subscription_status');
        const isReactivation = prop(subscriptionStatus === 'inactive' || subscriptionStatus === 'canceled');

        if (isEdit) {
            subscriptionVM
                .getSubscription(subscriptionId())
                .then(data => oldSubscription(_.first(data)))
                .catch(error);
        }

        if (_.isNull(currentUserID)) {
            projectVM.storeSubscribeAction(m.route.get());
            h.navigateToDevise(`?redirect_to=/projects/${project_id}`);
        }

        const reward = prop(rewardVM.selectedReward() || rewardVM.noReward);
        let value;

        if (_.isString(rewardVM.contributionValue())) {
            value = h.monetaryToFloat(rewardVM.contributionValue);
        } else {
            value = rewardVM.contributionValue();
        }

        const valueParam = m.route.param('contribution_value');
        const rewardIdParam = m.route.param('reward_id');


        if (valueParam) {
            value = rewardVM.contributionValue(Number(valueParam));
        }

        if (rewardIdParam) {
            rewardVM.fetchRewards(project_id).then(() => {
                reward(_.findWhere(rewardVM.rewards(), { id: Number(rewardIdParam) }));
                rewardVM.selectedReward(reward());
                m.redraw();
            });
        }

        const validateForm = () => {
            if (vm.validate()) {
                showPaymentForm(true);
                h.redraw();
            }
        };

        const fieldHasError = (fieldName) => {
            const fieldWithError = _.findWhere(vm.fields.errors(), {
                field: fieldName
            });

            return fieldWithError ? m(inlineError, {
                message: fieldWithError.message
            }) : '';
        };

        const applyDocumentMask = (value) => {
            if (value.length > 14) {
                isCnpj(true);
                vm.fields.ownerDocument(documentCompanyMask(value));
            } else {
                isCnpj(false);
                vm.fields.ownerDocument(documentMask(value));
            }
        };

        const addressChange = fn => (e) => {
            CatarseAnalytics.oneTimeEvent({
                cat: 'contribution_finish',
                act: vm.isInternational ? 'contribution_address_br' : 'contribution_address_int'
            });

            if (_.isFunction(fn)) {
                fn(e);
            }
        };

        const scope = attr => vm.isInternational() ?
            I18nIntScope(attr) :
            I18nScope(attr);

        const isLongDescription = reward => reward.description && reward.description.length > 110;

        vm.fetchUser().then(() => {

            countriesLoader
                .load()
                .then((countryData) => {
                    vm.fields.address().countries(_.sortBy(countryData, 'name_en'));
                    h.redraw();
                });
            h.redraw();
        });

        vnode.state = {
            project_id,
            addressChange,
            applyDocumentMask,
            fieldHasError,
            validateForm,
            showPaymentForm,
            reward,
            value,
            scope,
            isCnpj,
            isEdit,
            subscriptionId,
            isReactivation,
            vm,
            user,
            project,
            isLongDescription,
            oldSubscription,
            toggleDescription: h.toggleProp(false, true),
            subscriptionStatus
        };
    },
    view: function({state}) {
        const user = state.user(),
            project_id = state.project_id,
            project = state.project(),
            formatedValue = h.formatNumber(state.value, 2, 3),
            anonymousCheckbox = m('.w-row', [
                m('.w-checkbox.w-clearfix', [
                    m('input.w-checkbox-input[id=\'anonymous\'][name=\'anonymous\'][type=\'checkbox\']', {
                        onclick: () => CatarseAnalytics.event({
                            cat: 'contribution_finish',
                            act: 'contribution_anonymous_change'
                        }),
                        onchange: () => {
                            state.vm.fields.anonymous.toggle();
                        },
                        checked: state.vm.fields.anonymous()
                    }),
                    m('label.w-form-label.fontsize-smallest[for=\'anonymous\']',
                        window.I18n.t('fields.anonymous', state.scope())
                    )
                ]),
                (state.vm.fields.anonymous() ? m('.card.card-message.u-radius.zindex-10.fontsize-smallest',
                    m('div', [
                        m('span.fontweight-bold', [
                            window.I18n.t('anonymous_confirmation_title', state.scope()),
                            m('br')
                        ]),
                        m('br'),
                        window.I18n.t('anonymous_confirmation', state.scope())
                    ])
                ) : '')
            ]);

        return m('#project-payment', (state.vm.fields.address() && user && !_.isEmpty(project)) ? [
            m(`.w-section.section-product.${projectVM.currentProject().mode}`),
            m('.w-section.w-clearfix.section', [
                m('.w-col',
                    m('.w-clearfix.w-hidden-main.w-hidden-medium.card.u-radius.u-marginbottom-20', [
                        m('.fontsize-smaller.fontweight-semibold.u-marginbottom-20',
                            window.I18n.t('selected_reward.value', state.scope())
                        ),
                        m('.w-clearfix', [
                            m('.fontsize-larger.text-success.u-left',
                                `R$ ${formatedValue}`
                            ),
                            m(`a.alt-link.fontsize-smaller.u-right[href="/projects/${project_id}/subscriptions/start?${state.reward().id ? `reward_id=${state.reward().id}` : ''}${state.isEdit() ? `&subscription_id=${state.subscriptionId()}` : ''}${state.subscriptionStatus ? `&subscription_status=${state.subscriptionStatus}` : ''}"]`,
                                'Editar'
                            )
                        ]),
                        m('.divider.u-marginbottom-10.u-margintop-10'),
                        m('.back-payment-info-reward', [
                            m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10',
                                window.I18n.t('selected_reward.reward', state.scope())
                            ),
                            m('.fontsize-smallest.fontweight-semibold',
                                state.reward().title
                            ),
                            m('.fontsize-smallest.reward-description.opened.fontcolor-secondary', {
                                class: state.isLongDescription(state.reward()) ?
                                        state.toggleDescription() ? 'extended' : '' : 'extended'
                            }, state.reward().description ?
                                state.reward().description :
                                m.trust(
                                    window.I18n.t('selected_reward.review_without_reward_html',
                                        state.scope(
                                            _.extend({
                                                value: formatedValue
                                            })
                                        )
                                    )
                                )
                            ),
                            state.isLongDescription(state.reward()) ? m('a[href="javascript:void(0);"].link-hidden.link-more.u-marginbottom-20', {
                                onclick: state.toggleDescription.toggle
                            }, [
                                state.toggleDescription() ? 'menos ' : 'mais ',
                                m('span.fa.fa-angle-down', {
                                    class: state.toggleDescription() ? 'reversed' : ''
                                })
                            ]) : '',
                            state.reward().deliver_at ? m('.fontcolor-secondary.fontsize-smallest.u-margintop-10', [
                                m('span.fontweight-semibold',
                                    'Entrega prevista:'
                                ),
                                ` ${h.momentify(state.reward().deliver_at, 'MMM/YYYY')}`
                            ]) : '',
                            (rewardVM.hasShippingOptions(state.reward()) || state.reward().shipping_options === 'presential') ?
                            m('.fontcolor-secondary.fontsize-smallest', [
                                m('span.fontweight-semibold',
                                    'Forma de envio: '
                                ),
                                window.I18n.t(`shipping_options.${state.reward().shipping_options}`, {
                                    scope: 'projects.contributions'
                                })
                            ]) :
                            ''
                        ])
                    ])
                )
            ]),
            m('.w-container',
                m('.w-row', [
                    m('.w-col.w-col-8', [
                        m('.w-form', [
                            m('form.u-marginbottom-40', [
                                m('.u-marginbottom-40.u-text-center-small-only', [
                                    m('.fontweight-semibold.lineheight-tight.fontsize-large',
                                        window.I18n.t('title', state.scope())
                                    ),
                                    m('.fontsize-smaller',
                                        window.I18n.t('required', state.scope())
                                    )
                                ]),

                                (user.name && user.owner_document ?
                                    m('.card.card-terciary.u-radius.u-marginbottom-40', [
                                        m('.w-row.u-marginbottom-20', [
                                            m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2.w-hidden-tiny', [
                                                m(`img.thumb.u-margintop-10.u-round[src="${h.useAvatarOrDefault(user.profile_img_thumbnail)}"][width="100"]`)
                                            ]),
                                            m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10', [
                                                m('.fontcolor-secondary.fontsize-smallest.u-marginbottom-10', [
                                                    (project ? 'Dados do apoiador ' : 'Dados do usuário '),
                                                    m(`a.alt-link[href="/not-my-account?redirect_to=${encodeURIComponent(m.route.get())}"]`, 'Não é você?')
                                                ]),
                                                m('.fontsize-base.fontweight-semibold', user.name),
                                                (user.owner_document ?
                                                    m('label.field-label', `CPF/CNPJ: ${user.owner_document}`) : ''),

                                            ])
                                        ]),
                                        anonymousCheckbox

                                    ]) : ''),

                                (user.name && user.owner_document) ? '' : m('.card.card-terciary.u-radius.u-marginbottom-40', [
                                    (m('.w-row', [
                                        m('.w-col.w-col-7.w-sub-col', [
                                            m('label.field-label.fontweight-semibold[for=\'complete-name\']',
                                                window.I18n.t('fields.complete_name', state.scope())
                                            ),
                                            m('input.positive.w-input.text-field[id=\'complete-name\'][name=\'complete-name\']', {
                                                onfocus: state.vm.resetFieldError('completeName'),
                                                class: state.fieldHasError('completeName') ? 'error' : false,
                                                type: 'text',
                                                onchange: m.withAttr('value', state.vm.fields.completeName),
                                                value: state.vm.fields.completeName(),
                                                placeholder: 'Nome Completo'
                                            }),
                                            state.fieldHasError('completeName')
                                        ]),
                                        m('.w-col.w-col-5', state.vm.isInternational() ? '' : [
                                            m('label.field-label.fontweight-semibold[for=\'document\']',
                                                window.I18n.t('fields.owner_document', state.scope())
                                            ),
                                            m('input.positive.w-input.text-field[id=\'document\']', {
                                                onfocus: state.vm.resetFieldError('ownerDocument'),
                                                class: state.fieldHasError('ownerDocument') ? 'error' : false,
                                                type: 'tel',
                                                onkeyup: m.withAttr('value', state.applyDocumentMask),
                                                value: state.vm.fields.ownerDocument()
                                            }),
                                            state.fieldHasError('ownerDocument')
                                        ]),
                                    ])),
                                    anonymousCheckbox
                                ]),

                                m('.card.card-terciary.u-radius.u-marginbottom-40',
                                    m(addressForm, {
                                        addVM: state.vm.fields.address(),
                                        addressFields: state.vm.fields.address().fields,
                                        international: state.vm.isInternational,
                                        hideNationality: true
                                    })
                                )
                            ])
                        ]),
                        m('.w-row.u-marginbottom-40', !state.showPaymentForm() ? m('.w-col.w-col-push-3.w-col-6',
                            m('button.btn.btn-large', {
                                onclick: () => CatarseAnalytics.event({
                                    cat: 'contribution_finish',
                                    act: 'contribution_next_click'
                                }, state.validateForm)
                            },
                                window.I18n.t('next_step', state.scope())
                            )
                        ) : ''),
                        state.showPaymentForm() ? m(paymentForm, {
                            addressVM: state.vm.fields.address(),
                            vm: state.vm,
                            project_id,
                            isSubscriptionEdit: state.isEdit,
                            isReactivation: state.isReactivation,
                            subscriptionId: state.subscriptionId,
                            user_id: user.id,
                            reward: state.reward,
                            reward_common_id: state.reward().common_id,
                            project_common_id: projectVM.currentProject().common_id,
                            user_common_id: user.common_id,
                            isSubscription: true,
                            oldSubscription: state.oldSubscription,
                            value: state.value,
                            hideSave: true
                        }) : ''
                    ]),
                    m('.w-col.w-col-4', [
                        m('.card.u-marginbottom-20.u-radius.w-hidden-small.w-hidden-tiny', [
                            m('.fontsize-smaller.fontweight-semibold.u-marginbottom-20',
                                window.I18n.t('selected_reward.value', state.scope())
                            ),
                            m('.w-clearfix', [
                                m('.fontsize-larger.text-success.u-left',
                                    `R$ ${formatedValue}`
                                ),
                                m(`a.alt-link.fontsize-smaller.u-right[href="/projects/${project_id}/subscriptions/start?${state.reward().id ? `reward_id=${state.reward().id}` : ''}${state.isEdit() ? `&subscription_id=${state.subscriptionId()}` : ''}${state.subscriptionStatus ? `&subscription_status=${state.subscriptionStatus}` : ''}"]`,
                                    { oncreate: m.route.link },
                                    window.I18n.t('selected_reward.edit', state.scope())
                                )
                            ]),
                            m('.divider.u-marginbottom-10.u-margintop-10'),
                            m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10',
                                window.I18n.t('selected_reward.payment_plan', state.scope())
                            ),
                            m('.fontsize-smaller',
                                [
                                    m('span.fontweight-semibold',
                                        [
                                            m('span.fa.fa-money.text-success'),
                                            ` ${window.I18n.t('selected_reward.charged_today', state.scope())} `
                                        ]
                                    ),
                                    state.isEdit() && !state.isReactivation()
                                        ? ` ${window.I18n.t('invoice_none', I18nScope())}`
                                        : `R$ ${formatedValue}`
                                ]
                            ),
                            m('.fontsize-smaller.u-marginbottom-10',
                                [
                                    m('span.fontweight-semibold',
                                        [
                                            m('span.fa.fa-calendar-o.text-success'),
                                            ` ${window.I18n.t('selected_reward.next_charge', state.scope())} `
                                        ]
                                    ),
                                    state.isEdit() && !state.isReactivation()
                                        ? state.oldSubscription().next_charge_at
                                            ? h.momentify(state.oldSubscription().next_charge_at)
                                            : h.momentify(Date.now())
                                        : h.lastDayOfNextMonth()
                                ]
                            ),
                            m('.divider.u-marginbottom-10.u-margintop-10'),
                            m('.back-payment-info-reward', [
                                m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10',
                                    window.I18n.t('selected_reward.reward', state.scope())
                                ),
                                m('.fontsize-smallest.fontweight-semibold',
                                    state.reward().title
                                ),
                                m('.fontsize-smallest.reward-description.opened.fontcolor-secondary', {
                                    class: state.isLongDescription(state.reward()) ?
                                            state.toggleDescription() ? 'extended' : '' : 'extended'
                                }, state.reward().description ?
                                    state.reward().description :
                                    m.trust(
                                        window.I18n.t('selected_reward.review_without_reward_html',
                                            state.scope(
                                                _.extend({
                                                    value: Number(state.value).toFixed()
                                                })
                                            )
                                        )
                                    )
                                ),
                                state.isLongDescription(state.reward()) ? m('a[href="javascript:void(0);"].link-hidden.link-more.u-marginbottom-20', {
                                    onclick: state.toggleDescription.toggle
                                }, [
                                    state.toggleDescription() ? 'menos ' : 'mais ',
                                    m('span.fa.fa-angle-down', {
                                        class: state.toggleDescription() ? 'reversed' : ''
                                    })
                                ]) : ''
                            ]),
                        ]),
                        m(faqBox, {
                            mode: project.mode,
                            isEdit: state.isEdit(),
                            isReactivate: state.isReactivation(),
                            vm: state.vm,
                            faq: state.vm.faq(state.isEdit() ? state.isReactivation() ? `${project.mode}_reactivate` : `${project.mode}_edit` : project.mode),
                            projectUserId: project.user_id
                        })
                    ])
                ])
            )
        ] : h.loader());
    }
};

export default projectsSubscriptionCheckout;
