import m from 'mithril';

const bigInputCard = {
    view: function({attrs}) {
        const cardClass = attrs.cardClass || '.w-row.u-marginbottom-30.card.card-terciary.padding-redactor-description.text.optional.project_about_html.field_with_hint';

        return m(cardClass, { style: (attrs.cardStyle || {}) }, [
            m('div', [
                m('label.field-label.fontweight-semibold.fontsize-base', attrs.label),
                (attrs.label_hint ? m('label.hint.fontsize-smallest.fontcolor-secondary', attrs.label_hint) : '')
            ]),
            m('div', attrs.children)
        ]);
    }
};

export default bigInputCard;
