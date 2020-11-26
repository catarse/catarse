import m from 'mithril'
import { Event } from '../entities';

export type InputCardProps = {
    cardClass: string
    onclick(event : Event<MouseEvent>): void
    label: string
    label_hint: string
    children: m.ChildArrayOrPrimitive
    belowChildren: any
}

export default class InputCard {
    view({attrs, children} : m.Vnode<InputCardProps>) {
        const {
            cardClass = '.u-marginbottom-30.card.card-terciary',
            onclick = Function,
            label,
            label_hint,
            children: attrsChildren,
            belowChildren,
        } = attrs;

        return m(cardClass, { onclick }, [
            m('.w-row', [
                m('.w-col.w-col-5.w-sub-col', [
                    m('label.field-label.fontweight-semibold', label),
                    (label_hint ? m('label.hint.fontsize-smallest.fontcolor-secondary', attrs.label_hint) : '')
                ]),
                m('.w-col.w-col-7.w-sub-col', attrsChildren || children)
            ]),
            belowChildren
        ]);
    }
}
