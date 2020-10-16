import m from 'mithril'
import { ProjectDetails } from '../../../@types/project-details'

export type AskAboutRewardAttrs = {
    project: ProjectDetails
}

export class AskAboutReward implements m.Component {
    view({ attrs } : m.Vnode<AskAboutRewardAttrs>) {

        const project = attrs.project
        const userName = attrs.project.user?.public_name
        const askTo = userName || project.name

        return (
            <div class="section">
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-2"></div>
                        <div class="w-col w-col-8">
                            <div class="card medium card-terciary u-marginbottom-20">
                                <div class="title-dashboard">
                                    Você quer oferecer recompensas?
                                    <br/>
                                </div>
                                <div class="w-row">
                                    <div class="w-col w-col-1"></div>
                                    <div class="w-col w-col-10">
                                        <div class="fontsize-base u-text-center">
                                            Recompensas são uma funcionalidade opcional do Catarse, onde você pode oferecer algo em troca do apoio feito pelas pessoas. Se você quiser, pode publicar seu projeto sem recompensas e adicioná-las depois.
                                        </div>
                                    </div>
                                    <div class="w-col w-col-1"></div>
                                </div>
                                <div class="u-margintop-40 u-marginbottom-20 w-row">                            
                                    <div class="w-col w-col-6 w-sub-col u-marginbottom-20">
                                        <a href="#rewards" class="btn btn-large btn-terciary">
                                            Adicionar recompensas
                                        </a>
                                    </div>
                                    <div class="w-col w-col-6">
                                        <a href="#user" class="btn btn-large">
                                            Seguir sem recompensas
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="w-col w-col-2"></div>
                    </div>
                </div>
            </div>
        )
    }
}