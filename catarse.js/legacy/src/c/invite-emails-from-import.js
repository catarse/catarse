import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import h from '../h';
import models from '../models';
import { catarse } from '../api';

const inviteEmailsFromImport = {
    oninit: function(vnode) {
        const checkedList = prop([]),
            loading = prop(false),
            filterTerm = prop(''),
            filteredData = prop(vnode.attrs.dataEmails()),
            filtering = prop(false),
            onCheckGenerator = item => () => {
                const matchEmail = resource => resource.email === item.email;
                if (_.find(checkedList(), matchEmail)) {
                    checkedList(_.reject(checkedList(), matchEmail));
                } else {
                    checkedList().push(item);
                }
            },
            submitInvites = () => {
                loading(true);

                if (!_.isEmpty(checkedList)) {
                    catarse.loaderWithToken(
                          models.inviteProjectEmail.postOptions({
                              data: {
                                  project_id: vnode.attrs.project.project_id,
                                  emails: _.map(checkedList(), x => x.email)
                              }
                          })).load().then((data) => {
                              vnode.attrs.modalToggle.toggle();
                              loading(false);
                              vnode.attrs.showSuccess(true);
                          });
                }
            },
            search = () => {
                if (!filtering()) {
                    filtering(true);
                    let searchFilter;
                    const matchSearch = (item) => {
                        const pattern = `\b${_.escape(filterTerm())}`,
                            regex = new RegExp(pattern, 'gim');

                        return !_.isNull(item.email.match(regex)) || !_.isNull(item.name.match(regex));
                    };

                    if (!_.isEmpty(filterTerm()) || !_.isUndefined(filterTerm())) {
                        searchFilter = _.filter(vnode.attrs.dataEmails(), matchSearch);
                    }

                    filtering(false);
                    return searchFilter || vnode.attrs.dataEmails;
                }
            };

        vnode.state = {
            onCheckGenerator,
            submitInvites,
            checkedList,
            filterTerm,
            loading,
            search,
            filteredData,
            filtering
        };
    },
    view: function({state, attrs}) {
        const project = attrs.project;

        return m('div', [
            m('.modal-dialog-header', [
                m('.fontsize-large.u-text-center',
                  'Convide seus amigos')
            ]),
            m('.modal-dialog-content', (!attrs.loadingContacts() && !state.loading() ? [
                m('.filter-area', [
                    m('.w-row.u-margintop-20', [
                        m('.w-sub-col.w-col.w-col-12', [
                            m('form[action="javascript:void(0);"]', [
                                m('input.w-input.text-field[type="text"][placeholder="Busque pelo nome ou email."]', {
                                    onkeyup: m.withAttr('value', state.filterTerm),
                                    onchange: (e) => { e.preventDefault(); }
                                })
                            ])
                        ])
                    ])
                ]),
                m('.emails-area.u-margintop-40', { style: { height: '250px', 'overflow-x': 'auto' } },
                  (state.filtering() ? h.loader() : _.map(state.search(), (item, i) => m('.w-row.u-marginbottom-20', [
                      m('.w-sub-col.w-col.w-col-1', [
                          m(`input[type='checkbox'][name='check_${i}']`, { onchange: state.onCheckGenerator(item) })
                      ]),
                      m('.w-sub-col.w-col.w-col-4', [
                          m(`label.fontsize-small[for='check_${i}']`, item.name)
                      ]),
                      m('.w-sub-col.w-col.w-col-7', [
                          m(`label.fontsize-small.fontweight-semibold[for='check_${i}']`, item.email)
                      ])
                  ])))
                )
            ] : h.loader())),
            m('.modal-dialog-nav-bottom.u-text-center', [
                (!attrs.loadingContacts() && !state.loading() && !state.filtering() ?
                 m('.u-text-center.u-margintop-20', [
                     m('a.btn.btn-inline.btn-medium.w-button[href="javascript:void(0)"]', {
                         onclick: state.submitInvites
                     }, `Enviar ${state.checkedList().length} convites`)
                 ]) : (!state.loading() ? 'carregando contatos...' : 'enviando convites...'))
            ])
        ]);
    }
};

export default inviteEmailsFromImport;
