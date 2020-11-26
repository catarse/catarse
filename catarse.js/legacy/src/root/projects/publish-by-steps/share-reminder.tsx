import m from 'mithril'
import { ProjectDetails } from '../../../entities/project-details'

export type ShareReminderAttrs = {
    project: ProjectDetails
}

export class ShareReminder implements m.Component {
    view({ attrs } : m.Vnode<ShareReminderAttrs> ) {
        const project = attrs.project
        const projectUrl = `/projects/${project.id}/insights`

        return (
            <div class="section">
                <div class="w-container">
                    <div class="w-row">
                        <div class="w-col w-col-2"></div>
                        <div class="w-col w-col-8">
                            <div class="card medium card-terciary u-marginbottom-20">
                                <div class="title-dashboard big">
                                    Divulgar sua campanha é super importante!
                                    <br/>
                                </div>
                                <div class="w-row">
                                    <div class="w-col w-col-1"></div>
                                    <div class="u-text-center w-col w-col-10">
                                        <div class="divider u-marginbottom-20"></div>
                                        <img src="https://uploads-ssl.webflow.com/57ba58b4846cc19e60acdd5b/5ebd042f6f0ebfa4bdb69b7a_Asset%202%403x.png" width="115" alt="" class="u-marginbottom-30 u-margintop-30" />
                                        <div class="fontsize-small u-marginbottom-30">
                                            Você tentou usar todas as opções de compartilhamento? Falar com as pessoas sobre sua campanha é a única forma de começar a receber doações.
                                        </div>
                                        <a href="#share" class="btn btn-large btn-inline">
                                            Voltar e compartilhar mais
                                        </a>
                                    </div>
                                    <div class="w-col w-col-1"></div>
                                </div>
                                <div class="u-text-center u-margintop-30">
                                    <a href={projectUrl} class="fontsize-small link-hidden-dark">
                                        Gerenciar campanha
                                    </a>
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