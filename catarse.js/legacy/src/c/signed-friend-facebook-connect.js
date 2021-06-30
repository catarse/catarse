import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import connectFacebook from './connect-facebook';

const SignedFriendFacebookConnect = {
    oninit: function(vnode) {
        const mapWithAvatar = () => _.sample(_.filter(vnode.attrs.friendListVM.collection(), item => !_.isNull(item.avatar)), 8);

        vnode.state = {
            mapWithAvatar
        };
    },
    view: function({state, attrs}) {
        if (attrs.friendListVM.isLoading()) {
            return h.loader();
        }
        const total = attrs.friendListVM.total();
        return m('.w-section.section.bg-backs-carrosel.section-large', [
            m('.w-container', [
                m('.card.card-big', [
                    m('.w-row', [
                        m('.w-col.w-col-8', [
                            m('.fontsize-largest.u-marginbottom-20', 'Encontre projetos incríveis junto com seus amigos'),
                            m('.fontsize-small', 'O universo do Catarse junto com a sua rede do Facebook te farão descobrir projetos incríveis!')
                        ]),
                        m('.w-col.w-col-4.u-text-center', [
                            m('.fontsize-smallest.u-marginbottom-10', `${total} dos seus amigos estão no Catarse!`),
                            m('.u-marginbottom-20', [
                                _.map(state.mapWithAvatar(), item => m(`img.thumb.small.u-round.u-marginbottom-10[src="${item.avatar}"]`)),
                            ]),
                                (total > 0 ?
                                    m(connectFacebook, {
                                        label: 'Procure seus amigos',
                                        linkClass: 'a.w-button.btn.btn-large',
                                        buttonClass: 'input.btn.btn-fb.btn-large.u-margintop-30.u-marginbottom-10.w-button',
                                    }) : ''
                                )
                        ])
                    ])
                ])
            ])
        ]);
    }
};

export default SignedFriendFacebookConnect;
