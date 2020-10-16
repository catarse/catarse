import m from 'mithril';

const announceExpirationModal = {
    view: function({attrs}) {
        return m('div', [
            m('.modal-dialog-content', [
                m('.fontsize-large.u-text-center.u-marginbottom-30.fontweight-semibold',
                    'Você confirma?'
                ),
                m('.fontsize-large.u-text-center.u-marginbottom-30', [
                    'Sua arrecadação irá terminar no dia  ',
                    m('span.expire-date',
                        attrs.expirationDate
                    ),
                    ', as 23h59. Até lá, você pode captar recursos e seguir firme na sua campanha! Assim que o seu prazo chegar ao fim, você deverá confirmar os seus dados bancários. A partir de então, depositaremos o dinheiro na sua conta em 10 dias úteis.'
                ])
            ]),
            m('.modal-dialog-nav-bottom',
                m('.w-row', [
                    m('.w-col.w-col-2'),
                    m('.w-col.w-col-4', [
                        m("input[id='anchor'][name='anchor'][type='hidden'][value='announce_expiration']"),
                        m("input.btn.btn.btn-large[id='budget-save'][name='commit'][type='submit'][value='Sim']")
                    ]),
                    m('.w-col.w-col-4',
                        m('button.btn.btn-large.btn-terciary', {
                            onclick: attrs.displayModal.toggle
                        },
                            ' Não'
                        )
                    ),
                    m('.w-col.w-col-2')
                ])
            )
        ]);
    }
};

export default announceExpirationModal;
