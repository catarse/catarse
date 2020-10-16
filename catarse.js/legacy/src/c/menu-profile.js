import m from 'mithril';
import prop from 'mithril/stream';
import _ from 'underscore';
import userVM from '../vms/user-vm';
import h from '../h';
import models from '../models';
import { catarse } from '../api';

const menuProfile = {
    oninit: function(vnode) {
        const contributedProjects = prop(),
            latestProjects = prop([]),
            userDetails = prop({}),
            user_id = vnode.attrs.user.user_id,
            userBalance = prop(0),
            userIdVM = catarse.filtersVM({ user_id: 'eq' });

        const userName = () => {
            const name = userVM.displayName(userDetails());
            if (name && !_.isEmpty(name)) {
                return _.first(name.split(' '));
            }

            return '';
        };

        userVM.fetchUser(user_id, true, userDetails);

        userIdVM.user_id(user_id);
        models.balance.getRowWithToken(userIdVM.parameters()).then((result) => {
            const data = _.first(result) || { amount: 0, user_id };
            userBalance(data.amount);
        });

        vnode.state = {
            contributedProjects,
            latestProjects,
            userDetails,
            userName,
            toggleMenu: h.toggleProp(false, true),
            userBalance
        };
    },
    view: function({state, attrs}) {
        const user = state.userDetails();

        return m('.w-dropdown.user-profile',
            [
                m('.w-dropdown-toggle.dropdown-toggle.w-clearfix[id=\'user-menu\']',
                    {
                        onclick: state.toggleMenu.toggle
                    },
                    [
                        m('.user-name-menu', [
                            m('.fontsize-smaller.lineheight-tightest.text-align-right', state.userName()),
                            (state.userBalance() > 0 ? m('.fontsize-smallest.fontweight-semibold.text-success', `R$ ${h.formatNumber(state.userBalance(), 2, 3)}`) : '')

                        ]),
                        m(`img.user-avatar[alt='Thumbnail - ${user.name}'][height='40'][src='${h.useAvatarOrDefault(user.profile_img_thumbnail)}'][width='40']`)
                    ]
                ),
                state.toggleMenu() ? m('nav.w-dropdown-list.dropdown-list.user-menu.w--open[id=\'user-menu-dropdown\']', { style: 'display:block;' },
                    [
                        m('.w-row',
                            [
                                m('.w-col.w-col-12',
                                    [
                                        m('.fontweight-semibold.fontsize-smaller.u-marginbottom-10',
                                            'Meu histórico'
                                        ),
                                        m('ul.w-list-unstyled.u-marginbottom-20',
                                            [
                                                m('li.lineheight-looser',
                                                  m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}/edit#balance']`,
                                                    m('span', [
                                                        'Saldo ',
                                                        (state.userBalance() > 0 ? m('span.fontcolor-secondary',
                                                          `R$ ${h.formatNumber(state.userBalance(), 2, 3)}`) : ''),
                                                    ])
                                                   )
                                                 ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}/edit#contributions']`,
                                                        'Histórico de apoio'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                  m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}/edit#projects']`,
                                                    'Projetos criados'
                                                   )
                                                 )
                                            ]
                                        ),
                                        m('.fontweight-semibold.fontsize-smaller.u-marginbottom-10',
                                            'Configurações'
                                        ),
                                        m('ul.w-list-unstyled.u-marginbottom-20',
                                            [
                                                m('li.lineheight-looser',
                                                  m('a.alt-link.fontsize-smaller[href=\'/connect-facebook/\']',
                                                    'Encontre amigos'
                                                   ),
                                                 ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}/edit#about_me']`,
                                                        'Perfil público'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}/edit#notifications']`,
                                                        'Notificações'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href='/${window.I18n.locale}/users/${user.id}/edit#settings']`,
                                                        'Dados cadastrais'
                                                    )
                                                )
                                            ]
                                        ),
                                        m('.divider.u-marginbottom-20'),
                                        attrs.user.is_admin_role ? m('.fontweight-semibold.fontsize-smaller.u-marginbottom-10',
                                            'Admin'
                                        ) : '',
                                        attrs.user.is_admin_role ? m('ul.w-list-unstyled.u-marginbottom-20',
                                            [
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin#/home-banners\']`,
                                                        'Banners'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin#/users\']`,
                                                        'Usuários'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin\']`,
                                                        'Apoios'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                  m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin#/balance-transfers\']`,
                                                    'Saques'
                                                   )
                                                 ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/admin/financials\']`,
                                                        'Rel. Financeiros'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin#/projects\']`,
                                                        'Admin projetos'
                                                    )
                                                ),
                                                m('li.lineheight-looser',
                                                  m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin#/subscriptions\']`,
                                                    'Admin assinaturas'
                                                   )
                                                 ),
                                                m('li.lineheight-looser',
                                                  m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/new-admin#/notifications\']`,
                                                    'Admin notificações'
                                                   )
                                                ),
                                                m('li.lineheight-looser',
                                                    m(`a.alt-link.fontsize-smaller[href=\'/${window.I18n.locale}/dbhero\']`,
                                                        'Dataclips'
                                                    )
                                                )
                                            ]
                                        ) : '',
                                        m('.fontsize-mini', 'Seu e-mail de cadastro é: '),
                                        m('.fontsize-smallest.u-marginbottom-20', [
                                            m('span.fontweight-semibold', `${user.email} `),
                                            m(`a.alt-link[href='/${window.I18n.locale}/users/${user.id}/edit#about_me']`, 'alterar e-mail')
                                        ]),
                                        m('.divider.u-marginbottom-20'),
                                        m(`a.alt-link[href=\'/${window.I18n.locale}/logout\']`,
                                            'Sair'
                                        )
                                    ]
                                ),
                            ]
                        )
                    ]
                ) : ''
            ]
        );
    }
};

export default menuProfile;
