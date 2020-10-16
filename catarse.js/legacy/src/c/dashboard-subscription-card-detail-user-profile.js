import m from 'mithril';
import h from '../h';
import prop from 'mithril/stream';
import moment from 'moment';
import UserFollowBtn from './user-follow-btn';
import ownerMessageContent from './owner-message-content';
import modalBox from './modal-box';

const dashboardSubscriptionCardDetailUserProfile = {
    view: function({attrs})
    {
        const contactModalC = [ownerMessageContent, attrs.user];

        return m('.u-marginbottom-20.card.card-secondary.u-radius', [
            m('.fontsize-small.fontweight-semibold.u-marginbottom-10',
                'Perfil'
            ),
            m('.fontsize-smaller', [
                m('div',
                    attrs.subscription.user_email
                ),
                m('div',
                    `Conta no Catarse desde ${h.momentify(attrs.user.created_at, 'MMMM YYYY')}`
                ),
                m('.u-marginbottom-10', [
                    `Apoiou ${attrs.user.total_contributed_projects} projetos `,
                    m.trust('&nbsp;'),
                    '| ',
                    m.trust('&nbsp;'),
                    `Criou ${attrs.user.total_published_projects} projetos`
                ]),
                (attrs.displayModal() ? m(modalBox, {
                    displayModal: attrs.displayModal,
                    content: contactModalC
                }) : ''),
                (m('a.btn.btn-small.btn-inline.btn-edit.u-marginright-10.w-button', {
                    onclick: attrs.displayModal.toggle
                }, 'Enviar mensagem')),
                m(UserFollowBtn, {
                    follow_id: attrs.user.id,
                    following: attrs.user.following_this_user,
                    enabledClass: 'a.btn.btn-small.btn-inline.btn-terciary.w-button',
                    disabledClass: 'a.btn.btn-small.btn-inline.btn-terciary.w-button'
                })
            ])
        ]);
    }
};

export default dashboardSubscriptionCardDetailUserProfile;
