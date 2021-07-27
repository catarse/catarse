import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import popNotification from '../c/pop-notification';

const pixCard = {
    oninit: function (vnode) {
        const showPopNotification = prop(false),
              popNotificationAttributes = prop({});

        const copyToClipBoard = (str) => {
            const el = document.createElement('textarea');
            el.value = str;
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);
        };

        const onClickToCopyQrCode = () => {
            copyToClipBoard(vnode.attrs.pix_key)
            showPopNotification(true)
            popNotificationAttributes({
                message: window.I18n.t('shared.copied_code'),
                toggleOpt: showPopNotification
            });
            h.redraw()
        }
        vnode.state = {
            onClickToCopyQrCode,
            showPopNotification,
            popNotificationAttributes
        };
    },
    view: ({state, attrs}) => {
        return [
            m('.w-container.w-row',
                m('.u-text-center.w-col.w-col-6',
                m('.fontsize-base.fontweight-semibold', 'Leia com o app do seu banco'),
                m('div.u-margintop-30.u-marginbottom-20',
                    m.trust(attrs.pix_qr_code)
                ),
                m('.fontsize-base.fontweight-semibold.lineheight-tight.fontcolor-secondary', 'ou'),
                m('.fontsize-base.alt-link',
                    { onclick: state.onClickToCopyQrCode },
                    m('span.fa.fa-clipboard'),
                    m("a", {style: "cursor: copy"}, ' Copiar código do Pix')
                )
                ),
                m('.w-col.w-col-6.u-margintop-30',
                    m('.fontsize-base.u-margintop-30.card.card-big',
                        m('strong', '1' ),
                        '. Abra o app do seu banco ou instituição financeira e entre no ambiente ',
                        m('strong', 'Pix.' ),
                        m('br' ),
                        m('br' ),
                        m('strong', '2' ),
                        '. Escolha a opção ',
                        m('strong', 'Pagar com QR Code' ),
                        ' e escaneie o código ao lado.',
                        m('br' ),
                        m('br' ),
                        m('strong', '3' ),
                        '. Confirme as informações e finalize o apoio.'
                    )
                )
            ),
            state.showPopNotification() ? m(popNotification, state.popNotificationAttributes()) : ''
        ]
    }
};

export default pixCard;
