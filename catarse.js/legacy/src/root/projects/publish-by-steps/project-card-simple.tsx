import m from 'mithril'
import { Observable } from 'rxjs'
import { ProjectDetails } from '../../../entities/project-details'

export type ProjectCardSimpleAttrs = { 
    name: string
    headline: string
    image: string
}

export class ProjectCardSimple implements m.Component<ProjectCardSimpleAttrs> {
    view({ attrs } : m.Vnode<ProjectCardSimpleAttrs>) {

        const name = attrs.name
        const headline = attrs.headline
        const image = attrs.image
        
        const cardThumbStyle = {
            'background-image' : image ? `url(${image})` : 'url(https://s3.amazonaws.com/cdn.catarse/assets/thumb_generico_solidaria.png)'
        }

        return (
            <div class="card-project card u-radius">
                <div style={cardThumbStyle} class="card-project-thumb"></div>
                <div class="card-project-description">
                    <div class="fontweight-semibold fontsize-base u-marginbottom-10 u-text-center-small-only lineheight-tight">
                        {name}
                    </div>
                    <div class="fontcolor-secondary fontsize-smaller w-hidden-small w-hidden-tiny">
                        {headline}
                    </div>
                </div>
            </div>
        )
    }
}