import _ from 'underscore';

const startVM = (I18n) => {
    const i18nStart = I18n.translations[I18n.currentLocale()].pages.start,
        testimonials = i18nStart.testimonials,
        categoryProjects = i18nStart.categoryProjects,
        panes = i18nStart.panes,
        qa = i18nStart.qa;

    return {
        testimonials: _.map(testimonials, testimonial => ({
            thumbUrl: testimonial.thumb,
            content: testimonial.content,
            name: testimonial.name,
            totals: testimonial.totals
        })),
        panes: _.map(panes, pane => ({
            label: pane.label,
            src: pane.src
        })),
        questions: {
            col_1: _.map(qa.col_1, question => ({
                question: question.question,
                answer: question.answer
            })),
            col_2: _.map(qa.col_2, question => ({
                question: question.question,
                answer: question.answer
            }))
        },
        categoryProjects: _.map(categoryProjects, category => ({
            categoryId: category.category_id,
            sampleProjects: [
                category.sample_project_ids.primary,
                category.sample_project_ids.secondary
            ]
        }))
    };
};

export default startVM;
