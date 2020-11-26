import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'activerecord.attributes.address');

const surveyPreview = {
    oninit: function(vnode) {
        const fields = vnode.attrs.fields,
            multipleChoiceQuestions = vnode.attrs.multipleChoiceQuestions,
            openQuestions = vnode.attrs.openQuestions;

        vnode.state = {
            fields,
            multipleChoiceQuestions,
            openQuestions
        };
    },
    view: function({state, attrs}) {
        return m('.section.u-marginbottom-40',
            m('.w-container',
                m('.w-row', [
                    m('.w-col.w-col-1'),
                    m('.w-col.w-col-10',
                        m('.card.card-terciary.medium.u-radius', [
                            (attrs.confirmAddress ?
                            m('.u-marginbottom-30', [
                                m('.fontcolor-secondary.fontsize-base.fontweight-semibold.u-marginbottom-20',
                                    window.I18n.t('delivery_address', I18nScope())
                                ),
                                m('.fontsize-base', [
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('country', I18nScope())}: `
                                    ),
                                    attrs.countryName,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_street', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_street,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_number', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_number,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_complement', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_complement,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_neighbourhood', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_neighbourhood,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_city', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_city,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_state', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_state,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('address_zip_code', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.address_zip_code,
                                    m('br'),
                                    m('span.fontweight-semibold',
                                        `${window.I18n.t('phone_number', I18nScope())}:`
                                    ),
                                    m.trust('&nbsp;'),
                                    state.fields.phone_number
                                ])
                            ]) : ''),
                            _.map(state.multipleChoiceQuestions, (item) => {
                                const answer = _.find(item.question.question_choices, choice => item.value() == choice.id);
                                return m('.u-marginbottom-30', [
                                    m('.fontcolor-secondary.fontsize-base.fontweight-semibold',
                                        item.question.question
                                    ),
                                    m('.fontcolor-secondary.fontsize-smaller.u-marginbottom-20',
                                                        item.question.description
                                                    ),
                                    m('.fontsize-base', answer ? answer.option : '')
                                ]);
                            }),
                            _.map(state.openQuestions, item =>
                                m('.u-marginbottom-30', [
                                    m('.fontcolor-secondary.fontsize-base.fontweight-semibold',
                                        item.question.question
                                    ),
                                    m('.fontcolor-secondary.fontsize-smaller.u-marginbottom-20',
                                                        item.question.description
                                                    ),
                                    m('.fontsize-base', item.value())
                                ]))
                        ])
                    ),
                    m('.w-col.w-col-1')
                ])
            )
        );
    }
};

export default surveyPreview;
