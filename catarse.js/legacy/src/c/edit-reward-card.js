import m from 'mithril';
import prop from 'mithril/stream';
import moment from 'moment';
import _ from 'underscore';
import h from '../h';
import shippingFeeInput from '../c/shipping-fee-input';
import rewardVM from '../vms/reward-vm';
import projectVM from '../vms/project-vm';
import rewardCardEditDescription from './reward-card-edit-description';

const editRewardCard = {
    oninit: function(vnode) {
        const project = projectVM.getCurrentProject(),
            reward = vnode.attrs.reward(),
            imageFileToUpload = prop(null),
            minimumValue = projectVM.isSubscription(project) ? 5 : 10,
            destroyed = prop(false),
            isDeletingImage = prop(false),
            isUploadingImage = prop(false),
            isSavingReward = prop(false),
            acceptNumeric = (e) => {
                reward.minimum_value(e.target.value.replace(/[^0-9]/g, ''));
                return true;
            },
            confirmDelete = () => {
                const r = confirm('Você tem certeza?');
                if (r) {
                    if (reward.newReward) {
                        destroyed(true);
                        return false;
                    }
                    return m.request({
                        method: 'DELETE',
                        url: `/projects/${vnode.attrs.project_id}/rewards/${reward.id()}`,
                        config: h.setCsrfToken
                    }).then(() => {
                        destroyed(true);
                        m.redraw();
                    });
                }
                return false;
            },
            descriptionError = prop(false),
            minimumValueError = prop(false),
            deliverAtError = prop(false),
            states = prop([]),
            fees = prop([]),
            statesLoader = rewardVM.statesLoader,
            validate = () => {
                vnode.attrs.error(false);
                vnode.attrs.errors('Erro ao salvar informações. Confira os dados informados.');
                descriptionError(false);
                minimumValueError(false);
                deliverAtError(false);
                if (reward.newReward && moment(reward.deliver_at()).isBefore(moment().date(-1))) {
                    vnode.attrs.error(true);
                    deliverAtError(true);
                }
                if (_.isEmpty(reward.description())) {
                    vnode.attrs.error(true);
                    descriptionError(true);
                }
                if (!reward.minimum_value() || parseInt(reward.minimum_value()) < minimumValue) {
                    vnode.attrs.error(true);
                    minimumValueError(true);
                }
                _.map(fees(), (fee) => {
                    _.extend(fee, {
                        error: false
                    });
                    if (fee.destination() === null) {
                        vnode.attrs.error(true);
                        _.extend(fee, {
                            error: true
                        });
                    }
                });
            },
            onSelectImageFile = () => {
                const rewardImageFile = window.document.getElementById(`reward_image_file_open_card_${vnode.attrs.index}`);
                if (rewardImageFile.files.length) {
                    vnode.attrs.showImageToUpload(reward, imageFileToUpload, rewardImageFile.files[0]);
                }
            },
            tryDeleteImage = (reward) => {

                if (reward.newReward || imageFileToUpload()) {
                    reward.uploaded_image(null);
                    imageFileToUpload(null);
                } else {
                    isDeletingImage(true);
                    m.redraw();
                    vnode.attrs.deleteImage(reward, vnode.attrs.project_id, reward.id())
                        .then(r => {
                            if (r) {
                                imageFileToUpload(null);
                                reward.uploaded_image(null);
                            }

                            isDeletingImage(false);
                            m.redraw();
                        })
                        .catch(err => {
                            isDeletingImage(false);
                            m.redraw();
                        });
                }
            },
            saveReward = () => {
                isSavingReward(true);
                validate();
                if (vnode.attrs.error()) {
                    isSavingReward(false);
                    h.redraw();
                    return false;
                }
                const data = {
                    title: reward.title(),
                    project_id: vnode.attrs.project_id,
                    shipping_options: reward.shipping_options(),
                    minimum_value: reward.minimum_value(),
                    description: reward.description(),
                    deliver_at: reward.deliver_at()
                };
                if (reward.shipping_options() === 'national' || reward.shipping_options() === 'international') {
                    const shippingFees = _.map(fees(), fee => ({
                        _destroy: fee.deleted(),
                        id: fee.id(),
                        value: fee.value(),
                        destination: fee.destination()
                    }));
                    _.extend(data, {
                        shipping_fees_attributes: shippingFees
                    });
                }
                if (reward.newReward) {
                    isUploadingImage(true);
                    isSavingReward(false);
                    h.redraw();

                    rewardVM.createReward(vnode.attrs.project_id, data).then((r) => {
                            vnode.attrs.showSuccess(true);
                            reward.newReward = false;
                            // save id so we can update without reloading the page
                            reward.id(r.reward_id);
                            reward.edit.toggle();

                            vnode.attrs.uploadImage(reward, imageFileToUpload, vnode.attrs.project_id, r.reward_id)
                                .then(r_with_image => {
                                    vnode.attrs.showSuccess(true);
                                    isUploadingImage(false);
                                    h.redraw();
                                })
                                .catch(error => {
                                    vnode.attrs.showSuccess(false);
                                    isUploadingImage(false);
                                    h.redraw();
                                });
                            
                            isSavingReward(false);
                            h.redraw();
                        })
                        .catch(err => {
                            vnode.attrs.error(true);
                            vnode.attrs.errors('Erro ao salvar recompensa.');
                            isSavingReward(false);
                            h.redraw();
                        });
                } else {
                    isUploadingImage(true);
                    isSavingReward(false);
                    m.redraw();

                    rewardVM.updateReward(vnode.attrs.project_id, reward.id(), data).then(() => {
                        vnode.attrs.showSuccess(true);
                        reward.edit.toggle();

                        vnode.attrs.uploadImage(reward, imageFileToUpload, vnode.attrs.project_id, reward.id())
                            .then(r_with_image => {
                                vnode.attrs.showSuccess(true);
                                isUploadingImage(false);
                                h.redraw();
                            })
                            .catch(error => {
                                vnode.attrs.showSuccess(false);
                                isUploadingImage(false);
                                h.redraw();
                            });
                        isSavingReward(false);
                        h.redraw();
                    })
                    .catch(err => {
                        vnode.attrs.error(true);
                        vnode.attrs.errors('Erro ao salvar recompensa.');
                        isSavingReward(false);
                        h.redraw();
                    });
                }
                return false;
            },
            updateOptions = () => {
                const destinations = _.map(fees(), fee => fee.destination());
                if (((reward.shipping_options() === 'national' || reward.shipping_options() === 'international') && !_.contains(destinations, 'others'))) {
                    fees().push({
                        id: prop(null),
                        value: prop(0),
                        destination: prop('others')
                    });
                }
                if (reward.shipping_options() === 'national') {
                    fees(_.reject(fees(), fee => fee.destination() === 'international'));
                } else if (reward.shipping_options() === 'international' && !_.contains(destinations, 'international')) {
                    fees().push({
                        id: prop(null),
                        value: prop(0),
                        destination: prop('international')
                    });
                }
            };

        statesLoader.load().then((data) => {
            states(data);
            states().unshift({
                acronym: null,
                name: 'Estado'
            });

            if (!reward.newReward) {
                rewardVM.getFees({
                    id: reward.id()
                }).then((feeData) => {
                    _.map(feeData, (fee) => {
                        const feeProp = {
                            id: prop(fee.id),
                            value: prop(fee.value),
                            destination: prop(fee.destination)
                        };
                        fees().unshift(feeProp);
                    });
                    updateOptions();
                });
            }
        });

        vnode.state.minimumValueError = minimumValueError;
        vnode.state.minimumValue = minimumValue;
        vnode.state.deliverAtError = deliverAtError;
        vnode.state.descriptionError = descriptionError;
        vnode.state.confirmDelete = confirmDelete;
        vnode.state.acceptNumeric = acceptNumeric;
        vnode.state.updateOptions = updateOptions;
        vnode.state.saveReward = saveReward;
        vnode.state.destroyed = destroyed;
        vnode.state.states = states;
        vnode.state.project = project;
        vnode.state.reward = reward;
        vnode.state.fees = fees;
        vnode.state.tryDeleteImage = tryDeleteImage;
        vnode.state.onSelectImageFile = onSelectImageFile;
        vnode.state.isUploadingImage = isUploadingImage;
        vnode.state.isDeletingImage = isDeletingImage;
        vnode.state.isSavingReward = isSavingReward;
    },
    view: function({
        state,
        attrs
    }) {
        const newFee = {
                id: prop(null),
                value: prop(null),
                destination: prop(null)
            },
            fees = state.fees(),
            reward = attrs.reward(),
            inlineError = message => m('.fontsize-smaller.text-error.u-marginbottom-20.fa.fa-exclamation-triangle', m('span', message)),
            index = attrs.index,
            isUploadingImage = state.isUploadingImage(),
            isDeletingImage = state.isDeletingImage(),
            shouldAppearLoaderOnImageUploading = isUploadingImage || isDeletingImage,
            isSavingReward = state.isSavingReward(),
            descriptionError = state.descriptionError;

        return state.destroyed() ? m('div', '') : (isSavingReward ? h.loader() : m('.w-row.card-terciary.u-marginbottom-20.card-edition.medium', {
            class: attrs.class
        }, [
            m('.card',
                m('.w-form', [
                    m('.w-row', [
                        m('.w-col.w-col-5',
                            m('label.fontsize-smaller',
                                'Título:'
                            )
                        ),
                        m('.w-col.w-col-7',
                            m('input.w-input.text-field.positive[aria-required=\'true\'][autocomplete=\'off\'][type=\'tel\']', {
                                value: state.reward.title(),
                                oninput: m.withAttr('value', state.reward.title)
                            })
                        )
                    ]),
                    m('.w-row.u-marginbottom-20', [
                        m('.w-col.w-col-5',
                            m('label.fontsize-smaller',
                                'Valor mínimo:'
                            )
                        ),
                        m('.w-col.w-col-7', [
                            m('.w-row', [
                                m('.w-col.w-col-3.w-col-small-3.w-col-tiny-3.text-field.positive.prefix.no-hover',
                                    m('.fontsize-smallest.fontcolor-secondary.u-text-center',
                                        'R$'
                                    )
                                ),
                                m('.w-col.w-col-9.w-col-small-9.w-col-tiny-9',
                                    m('input.string.tel.required.w-input.text-field.project-edit-reward.positive.postfix[aria-required=\'true\'][autocomplete=\'off\'][required=\'required\'][type=\'tel\']', {

                                        class: state.minimumValueError() ? 'error' : false,
                                        value: state.reward.minimum_value(),
                                        oninput: e => state.acceptNumeric(e)
                                    })
                                )
                            ]),
                            state.minimumValueError() ? inlineError(`Valor deve ser igual ou superior a R$${state.minimumValue}.`) : '',

                            m('.fontsize-smaller.text-error.u-marginbottom-20.fa.fa-exclamation-triangle.w-hidden[data-error-for=\'reward_minimum_value\']',
                                'Informe um valor mínimo maior ou igual a 10'
                            )
                        ])
                    ]),
                    state.project.mode === 'sub' ? null : m('.w-row', [
                        m('.w-col.w-col-5',
                            m('label.fontsize-smaller',
                                'Previsão de entrega:'
                            )
                        ),
                        m('.w-col.w-col-7',
                            m('.w-row',
                                m('.w-col.w-col-12',
                                    m('.w-row', [
                                        m('input[type=\'hidden\'][value=\'1\']'),
                                        m('select.date.required.w-input.text-field.w-col-6.positive[aria-required=\'true\'][discard_day=\'true\'][required=\'required\'][use_short_month=\'true\']', {
                                            class: state.deliverAtError() ? 'error' : false,
                                            onchange: (e) => {
                                                state.reward.deliver_at(moment(state.reward.deliver_at()).month(parseInt(e.target.value) - 1).format());
                                            }
                                        }, [
                                            _.map(moment.monthsShort(), (month, monthIndex) => m('option', {
                                                    value: monthIndex + 1,
                                                    selected: moment(state.reward.deliver_at()).format('M') == monthIndex + 1
                                                },
                                                h.capitalize(month)
                                            ))
                                        ]),
                                        m('select.date.required.w-input.text-field.w-col-6.positive[aria-required=\'true\'][discard_day=\'true\'][required=\'required\'][use_short_month=\'true\']', {
                                            class: state.deliverAtError() ? 'error' : false,
                                            onchange: (e) => {
                                                state.reward.deliver_at(moment(reward.deliver_at()).year(parseInt(e.target.value)).format());
                                            }
                                        }, [
                                            _.map(_.range(moment().year(), moment().year() + 6), year =>
                                                m('option', {
                                                    value: year,
                                                    selected: moment(state.reward.deliver_at()).format('YYYY') === String(year)
                                                }, year))
                                        ])
                                    ])
                                )
                            ),
                            state.deliverAtError() ? inlineError('Data de entrega não pode ser no passado.') : '',
                        )
                    ]),

                    m(rewardCardEditDescription, {
                        reward, descriptionError, inlineError
                    }),

                    // REWARD IMAGE
                    (
                        (shouldAppearLoaderOnImageUploading) ?
                        (
                            h.loader()
                        ) :
                        (
                            (reward.uploaded_image && reward.uploaded_image()) ?
                            (
                                m("div.u-marginbottom-30.u-margintop-30",
                                    m("div.w-row", [
                                        m("div.w-col.w-col-5",
                                            m("label.fontsize-smaller[for='field-8']", [
                                                "Imagem",
                                                m("span.fontcolor-secondary", "(opcional)")
                                            ])
                                        ),
                                        m("div.w-col.w-col-7",
                                            m("div.u-marginbottom-20", [
                                                m("div.btn.btn-small.btn-terciary.fa.fa-lg.fa-trash.btn-no-border.btn-inline.u-right[href='#']", {
                                                    onclick: () => state.tryDeleteImage(reward)
                                                }),
                                                m(`img[src='${reward.uploaded_image()}'][alt='']`)
                                            ])
                                        )
                                    ])
                                )
                            ) :
                            (
                                m("div.u-marginbottom-30.u-margintop-30",
                                    m("div.w-row", [
                                        m("div.w-col.w-col-5",
                                            m("label.fontsize-smaller", [
                                                "Imagem ",
                                                m("span.fontcolor-secondary", "(opcional)")
                                            ])
                                        ),
                                        m("div.w-col.w-col-7",
                                            m(`input.text-field.w-input[type='file'][placeholder='Choose file'][id='reward_image_file_open_card_${index}']`, {
                                                oninput: () => state.onSelectImageFile(),
                                                onchange: () => state.onSelectImageFile(),
                                            })
                                        )
                                    ])
                                )
                            )
                        )
                    ),
                    // END REWARD IMAGE

                    state.project.mode === 'sub' ? null : m('.u-marginbottom-30.w-row', [
                        m('.w-col.w-col-3',
                            m("label.fontsize-smaller[for='field-2']",
                                'Tipo de entrega'
                            )
                        ),
                        m('.w-col.w-col-9', [
                            m('select.positive.text-field.w-select', {
                                value: state.reward.shipping_options() || 'free',
                                onchange: (e) => {
                                    state.reward.shipping_options(e.target.value);
                                    state.updateOptions();
                                }
                            }, [
                                m('option[value=\'international\']',
                                    'Frete Nacional e Internacional'
                                ),
                                m('option[value=\'national\']',
                                    'Frete Nacional'
                                ),
                                m('option[value=\'free\']',
                                    'Sem frete envolvido'
                                ),
                                m('option[value=\'presential\']',
                                    'Retirada presencial'
                                )
                            ]),

                            ((state.reward.shipping_options() === 'national' || state.reward.shipping_options() === 'international') ?
                                m('.card.card-terciary', [

                                    // state fees
                                    (_.map(fees, (fee, feeIndex) => [m(shippingFeeInput, {
                                            fee,
                                            fees: state.fees,
                                            feeIndex,
                                            states: state.states
                                        }),

                                    ])),
                                    m('.u-margintop-20',
                                        m("a.alt-link[href='#']", {
                                                onclick: () => {
                                                    state.fees().push(newFee);
                                                    return false;
                                                }
                                            },
                                            'Adicionar destino'
                                        )
                                    )
                                ]) : '')
                        ])
                    ]),
                    m('.w-row.u-margintop-30', [
                        m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5.w-sub-col-middle',
                            m('a.w-button.btn.btn-small', {
                                onclick: () => {
                                    state.saveReward();
                                }
                            }, 'Salvar')
                        ),
                        (reward.newReward ? '' :
                            m('.w-col.w-col-5.w-col-small-5.w-col-tiny-5.w-sub-col-middle',
                                m('a.w-button.btn-terciary.btn.btn-small.reward-close-button', {
                                    onclick: () => {
                                        reward.edit.toggle();
                                    }
                                }, 'Cancelar')
                            )),
                        m('.w-col.w-col-1.w-col-small-1.w-col-tiny-1', [
                            m('input[type=\'hidden\'][value=\'false\']'),
                            m('a.remove_fields.existing', {
                                    onclick: state.confirmDelete
                                },
                                m('.btn.btn-small.btn-terciary.fa.fa-lg.fa-trash.btn-no-border')
                            )
                        ])
                    ])
                ])
            )
        ]));
    }
};

export default editRewardCard;
