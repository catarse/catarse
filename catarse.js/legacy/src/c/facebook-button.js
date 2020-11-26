import m from 'mithril';

const facebookButton = {
    oninit: function(vnode) {
        const share = () => {
            if (FB) {
                FB.ui({
                    method: vnode.attrs.messenger ? 'send' : 'share',
                    link: vnode.attrs.url,
                    href: vnode.attrs.url,
                    display: 'popup',
                });
            }
        };

        vnode.state = {
            share
        };
    },
    view: function({state, attrs}) {
        const buttonCss = () => {
            if (attrs.mobile) {
                return `w-hidden-main w-hidden-medium u-marginbottom-20 btn btn-medium btn-fb ${attrs.class}`;
            } else if (attrs.big) {
                return `btn btn-fb btn-large u-marginbottom-20 w-button ${attrs.class}`;
            } else if (attrs.medium) {
                return `btn ${attrs.messenger ? 'btn-messenger' : 'btn-fb'} btn-medium u-marginbottom-20 w-button ${attrs.class}`;
            }
            return `btn btn-inline btn-medium btn-terciary u-marginright-20 ${attrs.class}`;
        };

        return m('button', {
            class: buttonCss(),
            onclick: state.share
        }, [
            m('span.fa', {
                class: attrs.messenger ? 'fa-comment' : 'fa-facebook'
            }),
            attrs.messenger ? ' Messenger' : ' Facebook'
        ]);
    }
};

export default facebookButton;
