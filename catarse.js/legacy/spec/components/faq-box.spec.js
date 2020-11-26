import mq from 'mithril-query';
import m from 'mithril';
import faqBox from '../../src/c/faq-box';

describe('FaqBox', () => {
    let $output,
        test = {
            description: 'faqBox description',
            questions: [
                {
                    question: 'question_1',
                    answer: 'answer_1'
                },
                {
                    question: 'question_2',
                    answer: 'answer_2'
                },
                {
                    question: 'question_3',
                    answer: 'answer_3'
                }
            ]
        };



    describe('view', () => {
        beforeAll(() => {
            $output = (mode = 'aon') => mq(
                m(faqBox, {
                    mode: mode,
                    vm: {
                        isInternational: () => false
                    },
                    faq: {
                        description: test.description,
                        questions: test.questions
                    },
                    projectUserId: 1
                })
            );
        });

        it('should build a faq box component', () => {
            const $contextOutput = $output();
            expect($contextOutput.has('.faq-box')).toBeTrue();
        });

        it('should show the set description', () => {
            const $contextOutput = $output();
            expect($contextOutput.contains(test.description)).toBeTrue();
        });

        it('should list all the questions', () => {
            const $contextOutput = $output();
            expect($contextOutput.find('.list-question').length).toEqual(test.questions.length);
        });

        it('should display the answer when clicking a question', () => {
            const $contextOutput = $output();
            $contextOutput.click('#faq_question_1');
            expect($contextOutput.has('.list-answer-opened > #faq_answer_1')).toBeTrue();
        });

        it('should set the correct badge icon acording to project mode', () => {
            const $contextOutputAon = $output('aon'),
                $contextOutputFlex = $output('flex');

            expect($contextOutputAon.has('img[src="/assets/aon-badge.png"]')).toBeTrue();
            expect($contextOutputFlex.has('img[src="/assets/flex-badge.png"]')).toBeTrue();
        });
    });
});
