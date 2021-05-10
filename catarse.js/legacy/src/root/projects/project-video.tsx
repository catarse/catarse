import { withHooks } from 'mithril-hooks'

export type ProjectVideoProps = {
    video_embed_url: string
}

export const ProjectVideo = withHooks<ProjectVideoProps>(_ProjectVideo)

function _ProjectVideo({video_embed_url}: ProjectVideoProps) {
    return (
        <div class="w-embed w-video project-video" component="projectVideo" style="min-height: 240px;">
            <iframe src={video_embed_url} frameborder="0" class="embedly-embed" itemprop="video" allowFullScreen></iframe>
        </div>
    )
}
