import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import rewardCardBig from './reward-card-big';

const I18nScope = _.partial(h.i18nScope, 'activerecord.attributes.address');

const surveyCreatePreview = {
    oninit: function(vnode) {
        const openQuestions = _.filter(vnode.attrs.surveyVM.dashboardQuestions(), { type: 'open' }),
            multipleChoiceQuestions = _.filter(vnode.attrs.surveyVM.dashboardQuestions(), { type: 'multiple' });
        const togglePreview = () => {
            vnode.attrs.showPreview.toggle();
            h.scrollTop();
        };

        vnode.state = {
            togglePreview,
            multipleChoiceQuestions,
            openQuestions
        };
    },
    view: function({state, attrs}) {
        return m('.section.u-marginbottom-40',
            m('.section.u-text-center',
                m('.w-container',
                    m('.w-row', [
                        m('.w-col.w-col-2'),
                        m('.w-col.w-col-8', [
                            m('.fontsize-larger.fontweight-semibold.lineheight-looser',
                                'Revise o questionário'
                            ),
                            m('.fontsize-base',
                                'Os seus apoiadores irão receber um link para o questionário abaixo por email. Veja se está tudo correto antes de enviá-lo!'
                            )
                        ]),
                        m('.w-col.w-col-2')
                    ])
                )
            ),


            m('.section',
                m('.w-container',
                    m('.w-row', [
                        m('.w-col.w-col-1'),
                        m('.w-col.w-col-10',
                            m('.card.card-terciary.medium.u-marginbottom-30', [
                                (attrs.confirmAddress ?
                                m('.u-marginbottom-30.w-form', [
                                    m('.fontcolor-secondary.fontsize-base.fontweight-semibold',
                                        'Endereço de entrega da recompensa'
                                    ),
                                    m('.fontcolor-secondary.fontsize-smaller.u-marginbottom-30',
                                        'Para onde Nome do Realizador deve enviar sua recompensa quando estiver pronta.'
                                    ),
                                    m('form', [
                                        m('.w-row', [
                                            m('.w-sub-col.w-col.w-col-6', [
                                                m('label.field-label.fontweight-semibold',
                                                    'País / Country'
                                                ),
                                                m('select.positive.text-field.w-select', [
                                                    m("option[value='']",
                                                        'Selecione...'
                                                    )
                                                ])
                                            ]),
                                            m('.w-col.w-col-6',
                                                m('.w-row', [
                                                    m('.w-sub-col-middle.w-col.w-col-6.w-col-small-6.w-col-tiny-6'),
                                                    m('.w-col.w-col-6.w-col-small-6.w-col-tiny-6')
                                                ])
                                            )
                                        ]),
                                        m('div', [
                                            m('label.field-label.fontweight-semibold',
                                                'Rua'
                                            ),
                                            m("input.positive.text-field.w-input[type='email']")
                                        ]),
                                        m('.w-row', [
                                            m('.w-sub-col.w-col.w-col-4', [
                                                m('label.field-label.fontweight-semibold',
                                                    'Número'
                                                ),
                                                m("input.positive.text-field.w-input[type='email']")
                                            ]),
                                            m('.w-sub-col.w-col.w-col-4', [
                                                m('label.field-label.fontweight-semibold',
                                                    'Complemento'
                                                ),
                                                m("input.positive.text-field.w-input[type='email']")
                                            ]),
                                            m('.w-col.w-col-4', [
                                                m('label.field-label.fontweight-semibold',
                                                    'Bairro'
                                                ),
                                                m("input.positive.text-field.w-input[type='email']")
                                            ])
                                        ]),
                                        m('.w-row', [
                                            m('.w-sub-col.w-col.w-col-4', [
                                                m('label.field-label.fontweight-semibold',
                                                    'CEP'
                                                ),
                                                m("input.positive.text-field.w-input[type='email']")
                                            ]),
                                            m('.w-sub-col.w-col.w-col-4', [
                                                m('label.field-label.fontweight-semibold',
                                                    'Cidade'
                                                ),
                                                m("input.positive.text-field.w-input[type='email']")
                                            ]),
                                            m('.w-col.w-col-4', [
                                                m('label.field-label.fontweight-semibold',
                                                    'Estado'
                                                ),
                                                m('select.positive.text-field.w-select', [
                                                    m("option[value='']",
                                                        'Selecione...'
                                                    )
                                                ])
                                            ])
                                        ]),
                                        m('.w-row', [
                                            m('.w-sub-col.w-col.w-col-6', [
                                                m('label.field-label.fontweight-semibold',
                                                    'Telefone'
                                                ),
                                                m("input.positive.text-field.w-input[type='email']")
                                            ]),
                                            m('.w-col.w-col-6')
                                        ])
                                    ])
                                ]) : ''),

                                _.map(state.multipleChoiceQuestions, question =>
                                m('.u-marginbottom-30.w-form', [
                                    m('.fontcolor-secondary.fontsize-base.fontweight-semibold',
                                      question.question
                                    ),
                                    m('.fontcolor-secondary.fontsize-smaller.u-marginbottom-20',
                                      question.description
                                    ),
                                    m('form', [
                                        _.map(question.survey_question_choices_attributes(), choice =>
                                        m('.fontsize-small.w-radio', [
                                            m("input.w-radio-input[type='radio'][value='Radio']"),
                                            m('label.w-form-label',
                                              choice.option
                                            )
                                        ]))
                                    ])
                                ])),
                                _.map(state.openQuestions, question =>
                                m('.u-marginbottom-30.w-form', [
                                    m('.fontcolor-secondary.fontsize-base.fontweight-semibold',
                                      question.question
                                    ),
                                    m('.fontcolor-secondary.fontsize-smaller.u-marginbottom-20',
                                        question.description
                                    ),
                                    m('form',
                                        m("input.positive.text-field.w-input[placeholder='Sua resposta'][type='text']")
                                    )
                                ]))
                            ])
                        ),
                        m('.w-col.w-col-1')
                    ])
                )
            ),
            m('.section', [
                m('.u-marginbottom-30.w-row', [
                    m('.w-col.w-col-2'),
                    m('.w-col.w-col-8', [
                        m('.u-marginbottom-30.u-text-center', [
                            m('.fontsize-small.fontweight-semibold.u-marginbottom-10',
                                `O questionário acima será enviado para os ${attrs.reward.paid_count} apoiadores da recompensa`
                            ),
                            m(rewardCardBig, { reward: attrs.reward })
                        ]),
                        m('.card.card-message.fontsize-small.u-marginbottom-30.u-radius', [
                            m('span.fontweight-semibold',
                                'OBS:'
                            ),
                            m.trust('&nbsp;'),
                            'As perguntas serão reenviadas automaticamente para aqueles que não responderem em até 4 dias. Caso os apoiadores continuem sem enviar as respostas, o questionário será reenviado mais duas vezes.'
                        ])
                    ]),
                    m('.w-col.w-col-2')
                ]),
                m('.u-marginbottom-20.w-row', [
                    m('.w-col.w-col-3'),
                    m('.w-sub-col.w-col.w-col-4',
                        m("a.btn.btn-large[href='javascript:void(0);']", { onclick: attrs.sendQuestions }, [
                            m('span.fa.fa-paper-plane',
                                ''
                            ),
                            ' ',
                            m.trust('&nbsp;'),
                            'Enviar'
                        ])
                    ),
                    m('.w-col.w-col-2',
                        m("a.btn.btn-large.btn-terciary[href='javascript:void(0);']", { onclick: state.togglePreview },
                            'Editar'
                        )
                    ),
                    m('.w-col.w-col-3')
                ])
            ])
        );
    }
};

export default surveyCreatePreview;
