import m from 'mithril';
import h from '../h';

const adminBalanceTransferItem = {
    view: function({attrs}) {
        const item = attrs.item;
        return m('.w-row', [
            m('.w-col.w-col-1.w-col-tiny-1', [
                m('.w-checkbox.w-clearfix', [
                    m('input.w-checkbox-input[type=\'checkbox\']', {
                        disabled: (item.state != 'pending'),
                        checked: attrs.listWrapper.isSelected(item.id),
                        onchange: (event) => {
                            if (event.currentTarget.checked) {
                                attrs.listWrapper.selectItem(item);
                            } else {
                                attrs.listWrapper.unSelectItem(item);
                            }
                        }
                    })
                ]),
            ]),
            m('.w-col.w-col-3', [
                m('.fontsize-smaller.fontweight-semibold.lineheight-tighter', [
                    `${item.user_name}`,
                    m('span.fontcolor-secondary.fontsize-smallest',
                      `(${item.user_public_name})`),
                ]),
                m('.fontcolor-secondary.fontsize-smallest',
                  item.user_email),
                m('.fontcolor-secondary.fontsize-smallest',
                  `USER_ID: ${item.user_id}`)
            ]),
            m('.w-col.w-col-2', [
                m('span.fontsize-small', `R$ ${h.formatNumber(item.amount, 2, 3)}`)
            ]),
            m('.w-col.w-col-2.w-hidden-small.w-hidden-tiny', [
                m('span', item.state),
                (item.transfer_id ? m('.fontcolor-secondary.fontsize-smallest',
                    m(`a[href="https://dashboard.pagar.me/#/transfers/${item.transfer_id}"]`,
                        `ID: ${item.transfer_id}`))
                    : '')
            ]),
            m('.w-col.w-col-2', [
                m('.fontsize-smallest', [
                    'Solicitado em: ',
                    m('span.fontsize-small.lineheight-tightest', h.momentify(item.created_at)),
                    m('br'),
                    m('span.fontsize-smallest.lineheight-tightest', `(${h.momentify(item.transfer_limit_date)})`)
                ])
            ]),
            m('.w-col.w-col-2', [
                m('.fontsize-smallest', [
                    'Confirmado em: ',
                    (item.transferred_at ? m('span.fontsize-small.lineheight-tightest', h.momentify(item.transferred_at)) : ''),
                ])
            ]),
        ]);
    }
};

export default adminBalanceTransferItem;
