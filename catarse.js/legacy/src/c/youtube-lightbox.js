/**
 * window.c.youtubeLightbox component
 * A visual component that displays a lightbox with a youtube video
 *
 * Example:
 * view: () => {
 *      ...
 *      m.component(c.youtubeLightbox, {src: 'https://www.youtube.com/watch?v=FlFTcDSKnLM'})
 *      ...
 *  }
 */

import m from 'mithril';
import _ from 'underscore';
import models from '../models';
import h from '../h';

const youtubeLightbox = {
    oninit: function(vnode) {
        let player;
        const showLightbox = h.toggleProp(false, true),
            setYoutube = () => {
                const tag = document.createElement('script'),
                    firstScriptTag = document.getElementsByTagName('script')[0];
                tag.src = 'https://www.youtube.com/iframe_api';
                firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
                window.onYouTubeIframeAPIReady = createPlayer;
            },
            closeVideo = () => {
                if (!_.isUndefined(player)) {
                    player.pauseVideo();
                }

                showLightbox.toggle();

                return false;
            },
            createPlayer = () => {
                player = new window.YT.Player('ytvideo', {
                    height: '528',
                    width: '940',
                    videoId: vnode.attrs.src,
                    playerVars: {
                        showInfo: 0,
                        modestBranding: 0
                    },
                    events: {
                        onStateChange: state => (state.data === 0) ? closeVideo() : false
                    }
                });
            };

        vnode.state = {
            showLightbox,
            setYoutube,
            closeVideo
        };
    },
    view: function({state, attrs}) {
        return m('#youtube-lightbox', [
            m('a#youtube-play.w-lightbox.w-inline-block.fa.fa-play-circle.fontcolor-negative.fa-5x[href=\'javascript:void(0);\']', {
                onclick: () => {
                    state.showLightbox.toggle();
                    attrs.onclick && attrs.onclick();
                }
            }),
            m(`#lightbox.w-lightbox-backdrop[style="display:${state.showLightbox() ? 'block' : 'none'}"]`, [
                m('.w-lightbox-container', [
                    m('.w-lightbox-content', [
                        m('.w-lightbox-view', [
                            m('.w-lightbox-frame', [
                                m('figure.w-lightbox-figure', [
                                    m('img.w-lightbox-img.w-lightbox-image[src=\'data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22940%22%20height=%22528%22/%3E\']'),
                                    m('#ytvideo.embedly-embed.w-lightbox-embed', { oncreate: state.setYoutube })
                                ])
                            ])
                        ]),
                        m('.w-lightbox-spinner.w-lightbox-hide'),
                        m('.w-lightbox-control.w-lightbox-left.w-lightbox-inactive'),
                        m('.w-lightbox-control.w-lightbox-right.w-lightbox-inactive'),
                        m('#youtube-close.w-lightbox-control.w-lightbox-close', { onclick: state.closeVideo })
                    ]),
                    m('.w-lightbox-strip')
                ])
            ])
        ]);
    }
};

export default youtubeLightbox;
