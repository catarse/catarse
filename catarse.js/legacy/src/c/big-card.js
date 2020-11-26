import m from 'mithril';

const bigCard = {
    view: function({attrs}) {
        const cardClass = '.card.medium.card-terciary.u-marginbottom-30';

        return m(cardClass, [
            m('div.u-marginbottom-30', [
                m('label.fontweight-semibold.fontsize-base', attrs.label),
                (attrs.label_hint ? m('.fontsize-small', attrs.label_hint) : '')
            ]),
            m('div', attrs.children)
        ]);
    }
};

export default bigCard;
