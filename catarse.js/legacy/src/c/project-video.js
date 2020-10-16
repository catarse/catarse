import m from 'mithril';

const projectVideo = {
    view({attrs}) {
        return m('.w-embed.w-video.project-video', { style : 'min-height: 240px;', component: 'projectVideo' }, [
            m(`iframe.embedly-embed[itemprop="video"][src="${attrs.video_embed_url}"][frameborder="0"][allowFullScreen]`)
        ]);
    }
}

export default projectVideo;