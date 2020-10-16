import m from 'mithril';

const projectReminderCount = {
    view: function({attrs}) {
        const project = attrs.resource;
        return m('#project-reminder-count.card.u-radius.u-text-center.medium.u-marginbottom-80', [
            m('.fontsize-large.fontweight-semibold', 'Total de pessoas que clicaram no botão Lembrar-me'),
            m('.fontsize-smaller.u-marginbottom-30', 'Um lembrete por email é enviado antes do término da sua campanha, convidando as pessoas a apoiarem na reta final!'),
            m('.fontsize-jumbo', project.reminder_count)
        ]);
    }
};

export default projectReminderCount;
