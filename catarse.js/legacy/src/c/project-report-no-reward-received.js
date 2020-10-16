/**
 * window.c.projectReportNoRewardReceived component
 * Render project report form
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import h from '../h';
import _ from 'underscore';
import ownerMessageContent from './owner-message-content';
import modalBox from './modal-box';

const projectReportNoRewardReceived = {
    oninit: function(vnode) {
        const formName = 'report-no-reward-received';
        const displayModal = h.toggleProp(false, true);
        const storeId = 'send-message';
        const sendMessage = () => {
            if (!h.getUser()) {
                h.storeAction(storeId, vnode.attrs.project.project_id);
                return h.navigateToDevise(`?redirect_to=/projects/${vnode.attrs.project.project_id}`);
            }

            displayModal(true);
        };

        if (h.callStoredAction(storeId) == vnode.attrs.project().project_id) {
            displayModal(true);
        }

        vnode.state = {
            displayModal,
            sendMessage,
            formName: vnode.attrs.formName || formName
        };
    },
    view: function({state, attrs}) {
        const contactModalC = [ownerMessageContent, prop(_.extend(attrs.user, {
            project_id: attrs.project().id
        }))];

        return m('.card.u-radius.u-margintop-20',
            [
                     (state.displayModal() ? m(modalBox, {
                         displayModal: state.displayModal,
                         content: contactModalC
                     }) : ''),
	                   m('.w-form',
		                   m('form',
			                   [
				                     m('.report-option.w-radio',
					                     [
						                       m('input.w-radio-input[type=\'radio\']', {
                           value: state.formName,
                           checked: attrs.displayFormWithName() === state.formName,
                           onchange: m.withAttr('value', attrs.displayFormWithName)
                       }),
						                       m('label.fontsize-small.fontweight-semibold.w-form-label', {
                           onclick: _ => attrs.displayFormWithName(state.formName)
                       }, 'Apoiei este projeto e ainda não recebi a recompensa')
					                     ]
				                      ),
				                     m('.u-margintop-30', {
                         style: {
                             display: attrs.displayFormWithName() === state.formName ? 'block' : 'none'
                         }
                     },
					                     m('.fontsize-small',
						                     [
							                       'Para saber sobre a de entrega da sua recompensa, você pode enviar uma',
							                       m('a.alt-link', {
                           style: {
                               cursor: 'pointer'
                           },
                           onclick: h.analytics.event({
                               cat: 'project_view',
                               act: 'project_creator_sendmsg',
                               lbl: attrs.user.id,
                               project: attrs.project()
                           }, state.sendMessage),
                           text: ' mensagem diretamente para o(a) Realizador(a)'
                       }),
							                       '.',
							                       m('br'),
							                       m('br'),
							                       'Veja',
							                       m('a.alt-link', {
                           href: 'https://suporte.catarse.me/hc/pt-br/articles/360000149946-Ainda-n%C3%A3o-recebi-minha-recompensa-E-agora-',
                           target: '_blank'
                       }, ' aqui '),
							                       'outras dicas sobre como acompanhar essa entrega.'
						                     ]
					                      )
				                      )
			                   ]
		                    )
	                    )
            ]);
    }
};

export default projectReportNoRewardReceived;
