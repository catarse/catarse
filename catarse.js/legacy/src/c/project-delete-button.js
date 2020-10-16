/**
 * window.c.projectDeleteButton component
 * A button showing modal to delete draft project
 */
import m from 'mithril';
import h from '../h';
import modalBox from '../c/modal-box';
import deleteProjectModalContent from '../c/delete-project-modal-content';

const projectDeleteButton = {
    oninit: function(vnode) {
        const displayDeleteModal = h.toggleProp(false, true);
        vnode.state = {
            displayDeleteModal
        };
    },
    view: function({state, attrs}) {
        return m('div', [
            (state.displayDeleteModal() ? m(modalBox, {
                displayModal: state.displayDeleteModal,
                hideCloseButton: true,
                content: [deleteProjectModalContent, { displayDeleteModal: state.displayDeleteModal, project: attrs.project }]
            }) : ''),
            m('.u-margintop-80',
              m('.w-container',
                m('a.btn.btn-inline.btn-no-border.btn-small.btn-terciary.u-marginbottom-20.u-right.w-button[href=\'javascript:void(0);\']', { onclick: state.displayDeleteModal.toggle, style: { transition: 'all 0.5s ease 0s' } },
                    [
                        m.trust('&nbsp;'),
                        'Deletar projeto ',
                        m('span.fa.fa-trash', ''
                    )
                    ]
                )
              )
            )]);
    }
};

export default projectDeleteButton;
