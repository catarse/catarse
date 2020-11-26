import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';

const openQuestionType = 'open',
    multipleQuestionType = 'multiple',
    newQuestion = () => ({
        type: openQuestionType,
        question: '',
        description: '',
        survey_question_choices_attributes: prop([
            {
                option: 'opção 1'
            },
            {
                option: 'opção 2'
            }
        ]),
        toggleDropdown: h.toggleProp(false, true)
    });

const dashboardQuestions = prop([newQuestion()]);
const confirmAddress = h.toggleProp(true, false);
const questionWithEmptyFields = prop([]);

const submitQuestions = rewardId => m.request({
    method: 'POST',
    url: `/rewards/${rewardId}/surveys`,
    data: {
        confirm_address: confirmAddress(),
        survey_open_questions_attributes: _.filter(dashboardQuestions(), { type: openQuestionType }),
        survey_multiple_choice_questions_attributes: _.filter(dashboardQuestions(), { type: multipleQuestionType })
    },
    config: h.setCsrfToken
});

const updateIfQuestion = questionToUpdate => (question, idx) => {
    if (idx === _.indexOf(dashboardQuestions(), questionToUpdate)) {
        return questionToUpdate;
    }

    return question;
};

const updateDashboardQuestion = questionToUpdate => _.compose(dashboardQuestions,
    _.map(dashboardQuestions(), updateIfQuestion(questionToUpdate))
);

const addDashboardQuestion = _.compose(dashboardQuestions, () => {
    dashboardQuestions().push(newQuestion());

    return dashboardQuestions();
});

const deleteDashboardQuestion = (question) => {
    dashboardQuestions(
        _.without(dashboardQuestions(), question)
    );
};

const addMultipleQuestionOption = (question) => {
    question.survey_question_choices_attributes().push({ option: '' });

    return false;
};

const deleteMultipleQuestionOption = (question, idx) => {
    question.survey_question_choices_attributes().splice(idx, 1);

    return false;
};

const isValid = () => {
    questionWithEmptyFields([]);

    return _.reduce(dashboardQuestions(), (isValid, question) => {
        if (isValid === false) {
            return isValid;
        }

        question.error = false;

        if (question.question.trim() === '') {
            questionWithEmptyFields().push(question);
            question.error = true;

            return false;
        }

        return true;
    }, true);
};

const surveyVM = {
    addDashboardQuestion,
    confirmAddress,
    dashboardQuestions,
    deleteDashboardQuestion,
    updateDashboardQuestion,
    deleteMultipleQuestionOption,
    addMultipleQuestionOption,
    submitQuestions,
    openQuestionType,
    multipleQuestionType,
    isValid
};

export default surveyVM;
