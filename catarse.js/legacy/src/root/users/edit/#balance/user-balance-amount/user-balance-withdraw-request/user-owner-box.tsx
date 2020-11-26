import m from 'mithril'
import h from '../../../../../../h'
import { withHooks } from 'mithril-hooks'
import { ProjectDetails, UserDetails, RewardDetails } from '../../../../../../entities'
import { InlineErrors } from '../../../../../../c/inline-errors'
import { BlockError } from '../../../../../../shared/components/block-error'
import { I18nText } from '../../../../../../shared/components/i18n-text'

export type UserOwnerBoxProps = {
    user: UserOwnerBoxDetails
    hideAvatar: boolean
    project?: ProjectDetails
    reward?: RewardDetails
    value?: number
    getErrors(field : string): string[]
}

export type UserOwnerBoxDetails = {
    id: number
    name: string
    profile_img_thumbnail?: string
    owner_document: string
}

export const UserOwnerBox = withHooks<UserOwnerBoxProps>(_UserOwnerBox)

function _UserOwnerBox({ project, user, hideAvatar, reward, value, getErrors } : UserOwnerBoxProps) {

    const notMyAccountParams = [
        project && `?project_id=${project.project_id}`,
        reward && `&reward_id=${reward.id}`,
        value && `&value=${value}`,
    ]

    const notMyAccountUrl = `/not-my-account?${notMyAccountParams.filter(p => !!p).join('&')}`

    const nameErrors = getErrors('owner_name')
    const documentErrors = getErrors('owner_document')
    const userNameErrors = getErrors('user_name')
    const hasUserNameErrors = userNameErrors.length > 0

    return (
        <div class='card card-terciary u-radius u-marginbottom-40'>
            <div class='w-row'>
                {
                    !hideAvatar && 
                    <div class='w-col w-col-2 w-col-small-2 w-col-tiny-2 w-hidden-tiny'>
                        <img src={h.useAvatarOrDefault(user.profile_img_thumbnail)} class='thumb u-margintop-10 u-round' width='100' />
                    </div>
                }
                <div class='w-col w-col-10 w-col-small-10 w-col-tiny-10'>
                    <div class='fontcolor-secondary fontsize-smallest u-marginbottom-10'>
                        {project ? 'Dados do apoiador ' : 'Dados do usuário '}
                        <a href={notMyAccountUrl} class='alt-link'>
                            Não é você?
                        </a>
                    </div>
                    <div class='fontsize-base fontweight-semibold'>
                        {user.name}
                    </div>
                    <InlineErrors messages={nameErrors} />
                    <label class='field-label'>
                        CPF/CNPJ: {user.owner_document}
                    </label>
                    <InlineErrors messages={documentErrors} />
                </div>
            </div>
            {
                hasUserNameErrors &&
                <BlockError>
                    <span>
                        <I18nText trust={true} scope='bank_accounts.edit.document_owner_mismatch_error' params={{profile_link: `/users/${user.id}/edit#settings`}} />
                    </span>
                </BlockError>
            }
        </div>
    )
}