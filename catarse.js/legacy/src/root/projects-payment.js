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
import faqBox from '../c/faq-box';
import nationalityRadio from '../c/nationality-radio';
import paymentForm from '../c/payment-form';
import inlineError from '../c/inline-error';
import addressForm from '../c/address-form';
import { catarse } from '../api';
import models from '../models';

const { CatarseAnalytics } = window;

const I18nScope = _.partial(h.i18nScope, 'projects.contributions.edit');
const I18nIntScope = _.partial(h.i18nScope, 'projects.contributions.edit_international');

const projectsPayment = {
    oninit: function (vnode) {

        const {
            ViewContentEvent,
            AddToCartEvent
        } = projectVM;

        projectVM.sendPageViewForCurrentProject(null, [ ViewContentEvent(), AddToCartEvent() ]);

        const project = projectVM.currentProject;
        const vm = paymentVM();
        const showPaymentForm = prop(false);
        const contribution = contributionVM.getCurrentContribution();
        const reward = prop(contribution().reward);
        const value = contribution().value;
        const documentMask = _.partial(h.mask, '999.999.999-99');
        const documentCompanyMask = _.partial(h.mask, '99.999.999/9999-99');
        const isCnpj = prop(false);
        const currentUserID = h.getUserID();
        const countriesLoader = catarse.loader(models.country.getPageOptions());
        const user = usersVM.getCurrentUser();

        vm.fields.address().setFields(vnode.attrs.address || vm.fields.address());

        const shippingFee = () =>
            _.findWhere(rewardVM.fees(), {
                id: contribution().shipping_fee_id,
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

        const fieldHasError = fieldName => {
            const fieldWithError = _.findWhere(vm.fields.errors(), {
                field: fieldName,
            });

            return fieldWithError
                ? m(inlineError, {
                    message: fieldWithError.message,
                })
                : '';
        };

        const applyDocumentMask = value => {
            if (value.length > 14) {
                isCnpj(true);
                vm.fields.ownerDocument(documentCompanyMask(value));
            } else {
                isCnpj(false);
                vm.fields.ownerDocument(documentMask(value));
            }
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

        vnode.state = {
            addressChange,
            applyDocumentMask,
            fieldHasError,
            validateForm,
            showPaymentForm,
            contribution,
            reward,
            value,
            scope,
            isCnpj,
            vm,
            user,
            project,
            shippingFee,
            isLongDescription,
            toggleDescription: h.toggleProp(false, true),
        };
    },
    view: function ({ state }) {
        const user = state.user(),
            project = state.project(),
            formatedValue = h.formatNumber(Number(state.value), 2, 3),
            anonymousCheckbox = m('.w-row', [
                m('.w-checkbox.w-clearfix', [
                    m("input.w-checkbox-input[id='anonymous'][name='anonymous'][type='checkbox']", {
                        onclick: () =>
                            CatarseAnalytics.event({
                                cat: 'contribution_finish',
                                act: 'contribution_anonymous_change',
                            }),
                        onchange: () => {
                            state.vm.fields.anonymous.toggle();
                        },
                        checked: state.vm.fields.anonymous(),
                    }),
                    m("label.w-form-label.fontsize-smallest[for='anonymous']", window.I18n.t('fields.anonymous', state.scope())),
                ]),

                state.vm.fields.anonymous()
                    ? m(
                        '.card.card-message.u-radius.zindex-10.fontsize-smallest',
                        m('div', [
                            m('span.fontweight-bold', [window.I18n.t('anonymous_confirmation_title', state.scope()), m('br')]),
                            m('br'),
                            window.I18n.t('anonymous_confirmation', state.scope()),
                        ])
                    )
                    : '',
            ]);

        return m(
            '#project-payment.w-section.w-clearfix.section',
            state.vm.fields.address() && !_.isEmpty(project)
                ? [
                    m(
                        '.w-col',
                        m('.w-clearfix.w-hidden-main.w-hidden-medium.card.u-radius.u-marginbottom-20', [
                            m('.fontsize-smaller.fontweight-semibold.u-marginbottom-20', window.I18n.t('selected_reward.value', state.scope())),
                            m('.w-clearfix', [
                                m('.fontsize-larger.text-success.u-left', `R$ ${formatedValue}`),
                                m(
                                    `a.alt-link.fontsize-smaller.u-right[href="/projects/${projectVM.currentProject().project_id}/contributions/new${
                                    state.reward().id ? `?reward_id=${state.reward().id}` : ''
                                    }"]`,
                                    'Editar'
                                ),
                            ]),
                            m('.divider.u-marginbottom-10.u-margintop-10'),
                            m('.back-payment-info-reward', [
                                m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10', window.I18n.t('selected_reward.reward', state.scope())),
                                m('.fontsize-smallest.fontweight-semibold', state.reward().title),
                                m(
                                    '.fontsize-smallest.reward-description.opened.fontcolor-secondary',
                                    {
                                        class: state.isLongDescription(state.reward()) ? (state.toggleDescription() ? 'extended' : '') : 'extended',
                                    },
                                    state.reward().description
                                        ? state.reward().description
                                        : m.trust(
                                            window.I18n.t(
                                                'selected_reward.review_without_reward_html',
                                                state.scope(
                                                    _.extend({
                                                        value: formatedValue,
                                                    })
                                                )
                                            )
                                        )
                                ),
                                state.isLongDescription(state.reward())
                                    ? m(
                                        'a[href="javascript:void(0);"].link-hidden.link-more.u-marginbottom-20',
                                        {
                                            onclick: state.toggleDescription.toggle,
                                        },
                                        [
                                            state.toggleDescription() ? 'menos ' : 'mais ',
                                            m('span.fa.fa-angle-down', {
                                                class: state.toggleDescription() ? 'reversed' : '',
                                            }),
                                        ]
                                    )
                                    : '',
                                state.reward().deliver_at
                                    ? m('.fontcolor-secondary.fontsize-smallest.u-margintop-10', [
                                        m('span.fontweight-semibold', 'Entrega prevista:'),
                                        ` ${h.momentify(state.reward().deliver_at, 'MMM/YYYY')}`,
                                    ])
                                    : '',
                                rewardVM.hasShippingOptions(state.reward()) || state.reward().shipping_options === 'presential'
                                    ? m('.fontcolor-secondary.fontsize-smallest', [
                                        m('span.fontweight-semibold', 'Forma de envio: '),
                                        window.I18n.t(`shipping_options.${state.reward().shipping_options}`, {
                                            scope: 'projects.contributions',
                                        }),
                                    ])
                                    : '',
                            ]),
                        ])
                    ),

                    m(
                        '.w-container',
                        m('.w-row', [
                            m('.w-col.w-col-8', [
                                m('.w-form', [
                                    m('form.u-marginbottom-40', [
                                        m('.u-marginbottom-40.u-text-center-small-only', [
                                            m('.fontweight-semibold.lineheight-tight.fontsize-large', window.I18n.t('title', state.scope())),
                                            m('.fontsize-smaller', window.I18n.t('required', state.scope())),
                                        ]),

                                        user.name && user.owner_document
                                            ? m('.card.card-terciary.u-radius.u-marginbottom-40', [
                                                m('.w-row.u-marginbottom-20', [
                                                    m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2.w-hidden-tiny', [
                                                        m(
                                                            `img.thumb.u-margintop-10.u-round[src="${h.useAvatarOrDefault(
                                                                user.profile_img_thumbnail
                                                            )}"][width="100"]`
                                                        ),
                                                    ]),
                                                    m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10', [
                                                        m('.fontcolor-secondary.fontsize-smallest.u-marginbottom-10', [
                                                            project ? 'Dados do apoiador ' : 'Dados do usuário ',
                                                            m(
                                                                `a.alt-link[href="/not-my-account${project ? `?project_id=${project.project_id}` : ''}${
                                                                state.reward() ? `&reward_id=${state.reward().id}` : ''
                                                                }${state.value ? `&value=${state.value * 100}` : ''}"]`,
                                                                'Não é você?'
                                                            ),
                                                        ]),
                                                        m('.fontsize-base.fontweight-semibold', user.name),
                                                        user.owner_document ? m('label.field-label', `CPF/CNPJ: ${user.owner_document}`) : '',
                                                    ]),
                                                ]),
                                                anonymousCheckbox,
                                            ])
                                            : '',
                                        // m(
                                        //     '.card.card-terciary.u-marginbottom-30.u-radius.w-form',
                                        //     m(nationalityRadio, {
                                        //         fields: addVM.fields,
                                        //         defaultCountryID: addVM.defaultCountryID,
                                        //         defaultForeignCountryID: addVM.defaultForeignCountryID,
                                        //         international: addVM.international,
                                        //     })
                                        // ),

                                        user.name && user.owner_document
                                            ? ''
                                            : m('.card.card-terciary.u-radius.u-marginbottom-40', [
                                                m('.w-row', [
                                                    m('.w-col.w-col-7.w-sub-col', [
                                                        m(
                                                            "label.field-label.fontweight-semibold[for='complete-name']",
                                                            window.I18n.t('fields.complete_name', state.scope())
                                                        ),
                                                        m("input.positive.w-input.text-field[id='complete-name'][name='complete-name']", {
                                                            onfocus: state.vm.resetFieldError('completeName'),
                                                            class: state.fieldHasError('completeName') ? 'error' : false,
                                                            type: 'text',
                                                            onchange: m.withAttr('value', state.vm.fields.completeName),
                                                            value: state.vm.fields.completeName(),
                                                            placeholder: 'Nome Completo',
                                                        }),
                                                        state.fieldHasError('completeName'),
                                                    ]),
                                                    m(
                                                        '.w-col.w-col-5',
                                                        state.vm.isInternational()
                                                            ? ''
                                                            : [
                                                                m(
                                                                    "label.field-label.fontweight-semibold[for='document']",
                                                                    window.I18n.t('fields.owner_document', state.scope())
                                                                ),
                                                                m("input.positive.w-input.text-field[id='document']", {
                                                                    onfocus: state.vm.resetFieldError('ownerDocument'),
                                                                    class: state.fieldHasError('ownerDocument') ? 'error' : false,
                                                                    type: 'tel',
                                                                    onkeyup: m.withAttr('value', state.applyDocumentMask),
                                                                    value: state.vm.fields.ownerDocument(),
                                                                }),
                                                                state.fieldHasError('ownerDocument'),
                                                            ]
                                                    ),
                                                ]),
                                                anonymousCheckbox,
                                            ]),

                                        m('.card.card-terciary.u-radius.u-marginbottom-40',
                                            m(addressForm, {
                                                addVM: state.vm.fields.address(),
                                                addressFields: state.vm.fields.address().fields,
                                                international: state.vm.isInternational,
                                                hideNationality: true,
                                            })
                                        ),
                                    ]),
                                ]),
                                m(
                                    '.w-row.u-marginbottom-40',
                                    !state.showPaymentForm()
                                        ? m(
                                            '.w-col.w-col-push-3.w-col-6',
                                            m(
                                                'button.btn.btn-large',
                                                {
                                                    onclick: () =>
                                                        CatarseAnalytics.event(
                                                            {
                                                                cat: 'contribution_finish',
                                                                act: 'contribution_next_click',
                                                            },
                                                            state.validateForm
                                                        ),
                                                },
                                                window.I18n.t('next_step', state.scope())
                                            )
                                        )
                                        : ''
                                ),
                                state.showPaymentForm()
                                    ? m(paymentForm, {
                                        vm: state.vm,
                                        contribution_id: state.contribution().id,
                                        project_id: projectVM.currentProject().project_id,
                                        user_id: user.id,
                                    })
                                    : '',
                            ]),
                            m('.w-col.w-col-4', [
                                m('.card.u-marginbottom-20.u-radius.w-hidden-small.w-hidden-tiny', [
                                    m('.fontsize-smaller.fontweight-semibold.u-marginbottom-20', window.I18n.t('selected_reward.value', state.scope())),
                                    m('.w-clearfix', [
                                        m('.fontsize-larger.text-success.u-left', `R$ ${formatedValue}`),
                                        m(
                                            `a.alt-link.fontsize-smaller.u-right[href="/projects/${projectVM.currentProject().project_id}/contributions/new${
                                            state.reward().id ? `?reward_id=${state.reward().id}` : ''
                                            }"]`,
                                            'Editar'
                                        ),
                                    ]),
                                    m('.divider.u-marginbottom-10.u-margintop-10'),
                                    m('.back-payment-info-reward', [
                                        m('.fontsize-smaller.fontweight-semibold.u-marginbottom-10', window.I18n.t('selected_reward.reward', state.scope())),
                                        m('.fontsize-smallest.fontweight-semibold', state.reward().title),
                                        m(
                                            '.fontsize-smallest.reward-description.opened.fontcolor-secondary',
                                            {
                                                class: state.isLongDescription(state.reward()) ? (state.toggleDescription() ? 'extended' : '') : 'extended',
                                            },
                                            state.reward().description
                                                ? state.reward().description
                                                : m.trust(
                                                    window.I18n.t(
                                                        'selected_reward.review_without_reward_html',
                                                        state.scope(
                                                            _.extend({
                                                                value: Number(state.value).toFixed(),
                                                            })
                                                        )
                                                    )
                                                )
                                        ),
                                        state.isLongDescription(state.reward())
                                            ? m(
                                                'a[href="javascript:void(0);"].link-hidden.link-more.u-marginbottom-20',
                                                {
                                                    onclick: state.toggleDescription.toggle,
                                                },
                                                [
                                                    state.toggleDescription() ? 'menos ' : 'mais ',
                                                    m('span.fa.fa-angle-down', {
                                                        class: state.toggleDescription() ? 'reversed' : '',
                                                    }),
                                                ]
                                            )
                                            : '',
                                        state.reward().deliver_at
                                            ? m('.fontcolor-secondary.fontsize-smallest.u-margintop-10', [
                                                m('span.fontweight-semibold', 'Entrega prevista:'),
                                                ` ${h.momentify(state.reward().deliver_at, 'MMM/YYYY')}`,
                                            ])
                                            : '',
                                        state.reward() && (rewardVM.hasShippingOptions(state.reward()) || state.reward().shipping_options === 'presential')
                                            ? m('.fontcolor-secondary.fontsize-smallest', [
                                                m('span.fontweight-semibold', 'Forma de envio: '),
                                                window.I18n.t(`shipping_options.${state.reward().shipping_options}`, {
                                                    scope: 'projects.contributions',
                                                }),
                                            ])
                                            : '',
                                        m(
                                            'div'
                                            // state.contribution().shipping_fee_id ? [
                                            //     m('.divider.u-marginbottom-10.u-margintop-10'),
                                            //     m('.fontsize-smaller.fontweight-semibold',
                                            //         'Destino da recompensa:'
                                            //     ),
                                            //     m(`a.alt-link.fontsize-smaller.u-right[href="/projects/${projectVM.currentProject().project_id}/contributions/new${state.reward().id ? `?reward_id=${state.reward().id}` : ''}"]`,
                                            //         'Editar'
                                            //     ),
                                            //     m('.fontsize-smaller', { style: 'padding-right: 42px;' },
                                            //         `${rewardVM.feeDestination(state.reward(), state.contribution().shipping_fee_id)}`
                                            //     ),
                                            //     m('p.fontsize-smaller', `(R$ ${rewardVM.shippingFeeById(state.contribution().shipping_fee_id) ? rewardVM.shippingFeeById(state.contribution().shipping_fee_id).value : '...'})`)
                                            // ] : ''
                                        ),
                                    ]),
                                ]),
                                m(faqBox, {
                                    mode: project.mode,
                                    vm: state.vm,
                                    faq: state.vm.faq(project.mode),
                                    projectUserId: project.user_id,
                                }),
                            ]),
                        ])
                    ),
                ]
                : h.loader()
        );
    },
};

export default projectsPayment;
