/**
 * window.c.OnlineSuccessModalContent component
 * Render online success message
 *
 */
import m from 'mithril';

const onlineSuccessModalContent = {
    view: function({state, attrs}) {
        return m('.modal-dialog-content.u-text-center', [
            m('.fa.fa-check-circle.fa-5x.text-success.u-marginbottom-40'),
            m('p.fontsize-larger.lineheight-tight', 'Sua campanha está no ar!!! Parabéns por esse primeiro grande passo. Boa sorte nessa jornada ;)')
        ]);
    }
};

export default onlineSuccessModalContent;
