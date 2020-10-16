import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import userVM from '../vms/user-vm';
import h from '../h';

const I18nScope = _.partial(h.i18nScope, 'projects.faq');

const faqBox = {
    oninit: function(vnode) {
        const mode = vnode.attrs.mode === 'sub' && vnode.attrs.isEdit ? vnode.attrs.isReactivate ? 'sub_reactivate' : 'sub_edit' : vnode.attrs.mode,
            questions = vnode.attrs.faq.questions,
            selectedQuestion = prop(-1),
            user = prop({ name: '...' }),
            tKey = () => !vnode.attrs.vm.isInternational()
                       ? `${mode}`
                       : `international.${mode}`;

        const selectQuestion = idx => () => idx === selectedQuestion()
                                              ? selectedQuestion(-1)
                                              : selectedQuestion(idx);

        // This function rewrites questions from translate with proper scope for links
        const scopedQuestions = () => {
            const updatedQuestions = {};
            _.each(questions, (quest, idx) => {
                _.extend(updatedQuestions, {
                    [idx + 1]: {
                        question: window.I18n.t(`${tKey()}.questions.${idx}.question`, I18nScope()),
                        answer: window.I18n.t(`${tKey()}.questions.${idx}.answer`,
                                    I18nScope(
                                        { userLink: `/users/${user().id}`,
                                            userName: user().public_name || user().name
                                        }
                                    )
                                )
                    }
                });
            });
            return updatedQuestions;
        };

        userVM.fetchUser(vnode.attrs.projectUserId, false).then(data => user(_.first(data)));

        vnode.state = {
            scopedQuestions,
            selectQuestion,
            selectedQuestion,
            tKey
        };
    },
    view: function({state, attrs}) {
        const image = attrs.mode === 'sub'
            ? m('div', m('img.u-marginbottom-10[width="130"][src="/assets/catarse_bootstrap/badge-sub-h.png"]'))
            : m('.w-col.w-col-2.w-col-small-2.w-col-tiny-2',
                m('img[width=\'30\']', {
                    src: attrs.mode === 'aon' ? '/assets/aon-badge.png' : '/assets/flex-badge.png'
                })
            );
        return m('.faq-box.w-hidden-small.w-hidden-tiny.card.u-radius',
            [
                m('.w-row.u-marginbottom-30',
                    [
                        image,
                        m('.w-col.w-col-10.w-col-small-10.w-col-tiny-10',
                            m('.w-inline-block.fontsize-smallest.w-inline-block.fontcolor-secondary',
                                window.I18n.t(`${state.tKey()}.description`, I18nScope())
                            )
                        )
                    ]
             ),
                m('.u-marginbottom-20.fontsize-small.fontweight-semibold',
                window.I18n.t(`${attrs.vm.isInternational() ? 'international_title' : 'title'}`, I18nScope())
            ),
                m('ul.w-list-unstyled',
                _.map(state.scopedQuestions(), (question, idx) => [
                    m(`li#faq_question_${idx}.fontsize-smaller.alt-link.list-question`, {
                        onclick: state.selectQuestion(idx)
                    }, m('span',
                        [
                            m('span.faq-box-arrow'),
                            ` ${question.question}`
                        ]
                          )
                        ),
                    m('li.list-answer', {
                        class: state.selectedQuestion() === idx ? 'list-answer-opened' : ''
                    }, m(`p#faq_answer_${idx}.fontsize-smaller`, m.trust(question.answer))
                        )
                ])
            )
            ]
        );
    }
};

export default faqBox;
