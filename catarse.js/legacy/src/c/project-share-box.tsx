import m from 'mithril';
import h from '../h';
import facebookButton from './facebook-button';

const projectShareBox = {
    oninit: function(vnode) {
        vnode.state = {
            displayEmbed: h.toggleProp(false, true)
        };
    },
    view: function({state, attrs}) {
        const utm = attrs.utm || 'ctrse_project_share';
        const ref = attrs.ref || 'ctrse_project_share';
        const embedUrl = `https://www.catarse.me/pt/projects/${attrs.project().project_id}/embed`;
        const facebookUrl = attrs.facebookUrl || `https://www.catarse.me/${attrs.project().permalink}?ref=${ref}&utm_source=facebook.com&utm_medium=social&utm_campaign=${utm}`;
        const facebookMessengerUrl = attrs.messengerUrl || `https://www.catarse.me/${attrs.project().permalink}?ref=${ref}&utm_source=facebook_messenger&utm_medium=social&utm_campaign=${utm}`;
        const whatsappUrl = `whatsapp://send?text=${encodeURIComponent(`https://www.catarse.me/${attrs.project().permalink}/?ref=${ref}&utm_source=whatsapp&utm_medium=social&utm_campaign=${utm}`)}`;
        const twitterUrl = `https://twitter.com/intent/tweet?text=Acabei%20de%20apoiar%20o%20projeto%20${encodeURIComponent(attrs.project().name)}%20https://www.catarse.me/${attrs.project().permalink}%3Fref%3D${ref}%26utm_source%3Dtwitter%26utm_medium%3Dsocial%26utm_campaign%3D${utm}`;
        const twitterSrc = `//platform.twitter.com/widgets/tweet_button.8d007ddfc184e6776be76fe9e5e52d69.en.html#_=1442425984936&count=horizontal&dnt=false&id=twitter-widget-1&lang=en&original_referer=https%3A%2F%2Fwww.catarse.me%2Fpt%2F${attrs.project().permalink}&size=m&text=Confira%20o%20projeto%20${attrs.project().name}%20no%20%40catarse&type=share&url=https%3A%2F%2Fwww.catarse.me%2Fpt%2F${attrs.project().permalink}%3Fref%3D${ref}%26utm_source%3Dtwitter%26utm_medium%3Dsocial%26utm_campaign%3D${utm}&via=catarse`;

        return m('.pop-share.fontcolor-primary', {
            style: 'display: block;'
        }, [
            m('.w-hidden-main.w-hidden-medium.w-clearfix', [
                m('a.btn.btn-small.btn-terciary.btn-inline.u-right', {
                    onclick: attrs.displayShareBox.toggle
                }, 'Fechar'),
                m('.fontsize-small.fontweight-semibold.u-marginbottom-30', 'Compartilhe este projeto')
            ]),
            m('.w-widget.w-widget-twitter.w-hidden-small.w-hidden-tiny.share-block', [
                m(`iframe[allowtransparency="true"][width="120px"][height="22px"][frameborder="0"][scrolling="no"][src="${twitterSrc}"]`)
            ]),
            m('a.w-hidden-small.widget-embed.w-hidden-tiny.fontsize-small.link-hidden.fontcolor-secondary[href="javascript:void(0);"]', {
                onclick: state.displayEmbed.toggle
            }, '< embed >'), (state.displayEmbed() ? m('.embed-expanded.u-margintop-30', [
                m('.fontsize-small.fontweight-semibold.u-marginbottom-20', 'Insira um widget em seu site'),
                m('.w-form', [
                    m(`input.w-input[type="text"][value="<iframe frameborder="0" height="340px" src="${embedUrl}" width="300px" scrolling="no"></iframe>"]`)
                ]),
                m('.card-embed', [
                    m(`iframe[frameborder="0"][height="350px"][src="/projects/${attrs.project().project_id}/embed"][width="300px"][scrolling="no"]`)
                ])
            ]) : ''),
            attrs.project().permalink ? m(facebookButton, {
                mobile: true,
                url: facebookUrl
            }) : '',
            attrs.project().permalink ? m(facebookButton, {
                mobile: true,
                messenger: true,
                url: facebookMessengerUrl
            }) : '',
            m(`a.w-hidden-main.w-hidden-medium.btn.btn-medium.btn-tweet.u-marginbottom-20[target="_blank"]`, {
                href: twitterUrl
            }, [
                m('span.fa.fa-twitter'), ' Tweet'
            ]),
            (
                h.isMobile() &&
                m('a.w-hidden-main.w-hidden-medium.btn.btn-medium[data-action="share/whatsapp/share"]', {
                    href: whatsappUrl
                }, [m('span.fa.fa-whatsapp'), ' Whatsapp'])
            )
        ]);
    }
};

export default projectShareBox;
