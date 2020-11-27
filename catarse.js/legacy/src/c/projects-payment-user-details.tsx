import { withHooks } from "mithril-hooks"
import { HTMLInputEvent, ProjectDetails, RewardDetails, UserDetails } from "../entities"
import h from "../h"
import { I18nText } from "../shared/components/i18n-text"
import { If } from "../shared/components/if"
import { InlineErrors } from "./inline-errors"
import AnonymousCheckbox from './projects-payment-anonymous-checkbox'

export const ProjectsPaymentUserDetails = withHooks<ProjectsPaymentUserDetailsProps>(_ProjectsPaymentUserDetails);

type ProjectsPaymentUserDetailsProps = {
    user: UserDetails
    reward: RewardDetails
    project: ProjectDetails
    value: number
    isAnonymous: boolean
    anonymousToggle(): void
    isInternational: boolean
    getErrors(field : string): string[]
    hasError(field : string): boolean
    onChangeFullName(newFullName : string): void
    fullName: string
    onChangeOwnerDocument(newOwnerDocument : string): void
    ownerDocument: string
    documentMask(newInputValue : string): string
}

function _ProjectsPaymentUserDetails(props : ProjectsPaymentUserDetailsProps) {

    const {
        user,
        project,
        reward,
        value,
        isAnonymous,
        anonymousToggle,
        isInternational,
        getErrors,
        hasError,
        onChangeFullName,
        fullName,
        onChangeOwnerDocument,
        ownerDocument,
        documentMask,
    } = props

    const userThumbnail = h.useAvatarOrDefault(user.profile_img_thumbnail)
    const scope = isInternational ? 'projects.contributions.edit_international' : 'projects.contributions.edit'

    if (user.name && user.owner_document) {

        const query = `${project ? `?project_id=${project.project_id}` : ''}${reward ? `&reward_id=${reward.id}` : ''}${value ? `&value=${value * 100}` : ''}`;

        return (
            <div className="card card-terciary u-radius u-marginbottom-40">
                <div className="w-row u-marginbottom-20">
                    <div className="w-col w-col-2 w-col-small-2 w-col-tiny-2 w-hidden-tiny">
                        <img src={userThumbnail} alt="" className="thumb u-margintop-10 u-round" width="100"/>
                    </div>
                    <div className="w-col w-col-10 w-col-small-10 w-col-tiny-10">
                        <div className="fontcolor-secondary fontsize-smallest u-marginbottom-10">
                            <If condition={!!project}>
                                Dados do apoiador&nbsp;
                            </If>
                            <If condition={!project}>
                                Dados do usuário&nbsp;
                            </If>
                            <a href={`/not-my-account${query}`} className="alt-link">
                                Não é você?
                            </a>
                        </div>

                        <div className="fontsize-base fontweight-semibold">
                            {user.name}
                        </div>

                        <If condition={!!user.owner_document}>
                            <label className="field-label">
                                CPF/CNPJ: {user.owner_document}
                            </label>
                        </If>
                    </div>
                </div>
                <AnonymousCheckbox
                    isInternational={isInternational}
                    isAnonymous={isAnonymous}
                    onChange={anonymousToggle}
                />
            </div>
        )
    } else {
        return (
            <div className="card card-terciary u-radius u-marginbottom-40">
                <div className="w-row">
                    <div className="w-col w-col-7 w-sub-col">
                        <label htmlFor="complete-name" className="field-label fontweight-semibold">
                            <I18nText scope={`${scope}.fields.complete_name`} />
                        </label>
                        <input
                            onfocus={(event : HTMLInputEvent) => onChangeFullName('')}
                            onchange={(event : HTMLInputEvent) => onChangeFullName(event.target.value)}
                            value={fullName}
                            placeholder="Nome Completo"
                            type="text"
                            className={`positive w-input text-field ${hasError('completeName') ? 'error' : ''}`}
                            id="complete-name"
                            name="complete-name"
                        />
                        <InlineErrors messages={getErrors('completeName')} />
                    </div>

                    <div className="w-col w-col-5">
                        <If condition={!isInternational}>
                            <label htmlFor="document" className="field-label fontweight-semibold">
                                <I18nText scope={`${scope}.fields.owner_document`} />
                            </label>
                            <input
                                onfocus={(event : HTMLInputEvent) => onChangeOwnerDocument('')}
                                onkeyup={(event : HTMLInputEvent) => onChangeOwnerDocument(documentMask(event.target.value))}
                                value={ownerDocument}
                                type="tel"
                                className={`positive w-input text-field ${hasError('ownerDocument') ? 'error' : ''}`}
                                id="document"
                            />
                            <InlineErrors messages={getErrors('ownerDocument')} />
                        </If>
                    </div>
                </div>
                <AnonymousCheckbox
                    isInternational={isInternational}
                    isAnonymous={isAnonymous}
                    onChange={anonymousToggle}
                />
            </div>
        )
    }
}
