import m from 'mithril';
import _ from 'underscore';
import h from '../h';

const UnsignedFriendFacebookConnect = {
    oninit: function(vnode) {
        vnode.state = {
            largeBg: (() => {
                if (_.isUndefined(vnode.attrs)) {
                    return false;
                }
                return _.isUndefined(vnode.attrs.largeBg) ? false : vnode.attrs.largeBg;
            })()
        };
    },
    view: function({state}) {
        return m(`.w-section.section${(state.largeBg ? '.bg-backs-carrosel.section-large' : '')}`, [
            m('.w-container', [
                m('.card.card-big', [
                    m('.w-row', [
                        m('.w-col.w-col-8', [
                            m('.fontsize-largest.u-marginbottom-20', 'Encontre projetos incríveis junto com seus amigos'),
                            m('.fontsize-small', 'O universo do Catarse junto com a sua rede do Facebook te farão descobrir projetos incríveis!')
                        ]),
                        m('.w-col.w-col-4', [
                            m('a.w-button.btn.btn-fb.btn-large.u-margintop-30.u-marginbottom-10[href="/connect-facebook"]', 'Conecte seu facebook'),
                            m('.fontsize-smallest.fontcolor-secondary.u-text-center', 'Nós nunca postaremos nada no facebook sem sua permissão')
                        ])
                    ])
                ])
            ])
        ]);
    }
};

export default UnsignedFriendFacebookConnect;
