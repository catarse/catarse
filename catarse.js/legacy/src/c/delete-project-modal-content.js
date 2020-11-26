/**
 * window.c.deleteProjectModalContent component
 * Render delete project modal
 *
 */
import m from 'mithril';
import prop from 'mithril/stream';
import { catarse } from '../api';
import h from '../h';
import models from '../models';

const deleteProjectModalContent = {
    oninit: function(vnode) {
        let l = prop(false);
        const deleteSuccess = prop(false),
            confirmed = prop(true),
            error = prop(''),
            check = prop('');

        const deleteProject = () => {
            if (check() === 'deletar-rascunho') {
                const loaderOpts = models.deleteProject.postOptions({
                    _project_id: vnode.attrs.project.project_id
                });
                l = catarse.loaderWithToken(loaderOpts);
                l.load().then(() => {
                    deleteSuccess(true);
                }).catch((err) => {
                    confirmed(false);
                    error('Erro ao deletar projeto. Por favor tente novamente.');
                    m.redraw();
                });
            } else {
                confirmed(false);
                error('Por favor, corrija os seguintes erros: para deletar definitivamente o projeto você deverá preencher "deletar-rascunho".');
            }
            return false;
        };

        vnode.state = {
            deleteProject,
            confirmed,
            deleteSuccess,
            error,
            check
        };
    },
    view: function({state, attrs}) {
        return m('div',
                 (state.deleteSuccess() ? '' : m('.modal-dialog-header',
                  m('.fontsize-large.u-text-center',
                      [
                          'Confirmar ',
                          m('span.fa.fa-trash',
                        ''
                      )
                      ]
                  )
                )),
                m('form.modal-dialog-content', { onsubmit: state.deleteProject },
                  (state.deleteSuccess() ? [m('.fontsize-base.u-margintop-30', 'Projeto deletado com sucesso. Clique no link abaixo para voltar a página inicial.'),
                      m(`a.btn.btn-inactive.btn-large.u-margintop-30[href='/${window.I18n.locale}/users/${h.getUser().user_id}/edit#projects']`, 'Voltar')
                  ] :
                  [
                      m('.fontsize-base.u-marginbottom-60',
                          [
                              'O projeto será deletado permanentemente e todos os dados que você preencheu na edição do rascunho não poderão ser recuperados.'
                          ]
                    ),
                      m('.fontsize-base.u-marginbottom-10',
                          [
                              'Confirme escrevendo ',
                              'no campo abaixo ',
                              m('span.fontweight-semibold.text-error',
                          'deletar-rascunho'
                        )
                          ]
                    ),
                      m('.w-form',
                      m('.text-error.u-marginbottom-10', state.error()),
                          [
                              m('div',
                          m('input.positive.text-field.u-marginbottom-40.w-input[maxlength=\'256\'][type=\'text\']', { class: state.confirmed() ? false : 'error', placeholder: 'deletar-rascunho', onchange: m.withAttr('value', state.check) })
                        )
                          ]
                    ),
                      m('div',
                      m('.w-row',
                          [
                              m('.w-col.w-col-3'),
                              m('.u-text-center.w-col.w-col-6',
                                  [
                                      m('input.btn.btn-inactive.btn-large.u-marginbottom-20[type=\'submit\'][value=\'Deletar para sempre\']'),
                                      m('a.fontsize-small.link-hidden-light[href=\'#\']', { onclick: attrs.displayDeleteModal.toggle }, 'Cancelar'
                              )
                                  ]
                          ),
                              m('.w-col.w-col-3')
                          ]
                      )
                    )
                  ])
                ));
    }
};

export default deleteProjectModalContent;
