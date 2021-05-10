import m from 'mithril'
import { useRef, useState, withHooks } from 'mithril-hooks'
import { ProjectDetails } from '../../../../entities'
import h from '../../../../h'
import { ClipboardField } from '../../../../shared/components/clipboard-field'
import { share, SocialMediaShareType } from '../../../../shared/services/share/share'
import { PageInfoText } from './page-info-text'

export type ComingSoonActivatedProps = {
    project: ProjectDetails
    permalink: string
    following: number
    deactivate: () => void
}

export const ComingSoonActivated = withHooks<ComingSoonActivatedProps>(_ComingSoonActivated)

function _ComingSoonActivated({project, permalink, following, deactivate}: ComingSoonActivatedProps) {
    const baseUrl = `${location.protocol}//${location.host}`
    const permalinkUrl = `${baseUrl}/${permalink}`

    const onClickShare = (event: Event, shareType: SocialMediaShareType) => {
        event.preventDefault()
        share(shareType, permalinkUrl)
    }

    return (
        <div class="section">
            <div class="w-container">
                <div class="w-row">
                    <div class="w-col w-col-1"></div>
                    <div class="w-col w-col-10">
                        <div class="card u-radius u-marginbottom-20 card-terciary w-clearfix">
                            <div class="invite-friends-back-col-1">
                                <div class="fontsize-base fontweight-semibold u-marginbottom-10">
                                    Página de pré-lançamento
                                </div>
                                <div class="card u-radius u-marginbottom-20">
                                    <div class="fontsize-base">
                                        <span class="fa fa-circle text-success"></span>&nbsp;
                                        Ativa
                                    </div>
                                    <div class="divider u-marginbottom-10 u-margintop-10"></div>
                                    <div class="fontsize-large fontweight-semibold">
                                        {following === 1 ? `${following} pessoa` : `${following} pessoas`}
                                    </div>
                                    <div class="fontsize-smaller fontcolor-secondary">
                                        seguindo o projeto
                                    </div>
                                </div>
                                <PageInfoText project={project} class="u-marginbottom-20" />
                                <div class="w-row">
                                    <div class="w-col w-col-6">
                                        <a href={`/${permalink}`} target="_blank" class="btn btn-small btn-terciary btn-inline btn-no-border w-button">
                                            <span class="fa fa-eye"></span>&nbsp;
                                            Visualizar página
                                        </a>
                                    </div>
                                    <div class="w-col w-col-6">
                                        <a onclick={deactivate} href="#" class="btn btn-small btn-terciary btn-inline btn-no-border w-button">
                                            Desativar
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="invite-friends-back-col-2">
                                <div class="fontsize-base fontweight-semibold u-marginbottom-10">
                                    Convide sua comunidade
                                </div>
                                <a onclick={e => onClickShare(e, SocialMediaShareType.Facebook)} href="#" class="btn btn-medium btn-fb u-marginbottom-20 w-button">
                                    <span class="fa fa-facebook"></span>&nbsp;
                                    Facebook
                                </a>
                                <a onclick={e => onClickShare(e, SocialMediaShareType.Messenger)} href="#" class="btn btn-medium btn-messenger u-marginbottom-20 w-button">
                                    <span class="fa fa-comment"></span>&nbsp;
                                    Messenger
                                </a>
                                <div class="w-form">
                                    <form id="email-form-2" name="email-form-2" data-name="Email Form 2">
                                        <div class="fontsize-smallest fontcolor-secondary">Link direto</div>
                                        <ClipboardField
                                            text={permalinkUrl}
                                            placeholder="www.catarse.me/linkdoprojeto" />
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="w-col w-col-1"></div>
                </div>
            </div>
        </div>
    )
}
