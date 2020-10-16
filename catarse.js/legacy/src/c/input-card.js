import m from 'mithril';

const inputCard = {
    view: function({attrs}) {
        const cardClass = attrs.cardClass || '.u-marginbottom-30.card.card-terciary',
            onclick = attrs.onclick || Function.prototype;

        return m(cardClass, { onclick }, [
            m('.w-row', [
                m('.w-col.w-col-5.w-sub-col', [
                    m('label.field-label.fontweight-semibold', attrs.label),
                    (attrs.label_hint ? m('label.hint.fontsize-smallest.fontcolor-secondary', attrs.label_hint) : '')
                ]),
                m('.w-col.w-col-7.w-sub-col', attrs.children)
            ]),

            attrs.belowChildren
        ]);
    }
};

export default inputCard;
