import { useState, withHooks } from "mithril-hooks"
import { ProjectDetails, RewardDetails } from "../entities"
import { CurrencyFormat } from "../shared/components/currency-format"
import { DateFormat } from "../shared/components/date-format"
import { I18nText } from "../shared/components/i18n-text"
import { If } from "../shared/components/if"
import rewardVM from "../vms/reward-vm"

export const ProjectsPaymentRewardDetails = withHooks<ProjectsPaymentRewardDetailsProps>(_ProjectsPaymentRewardDetails)

type ProjectsPaymentRewardDetailsProps = {
    isInternational: boolean
    project: ProjectDetails
    reward: RewardDetails
    value: number
}

function _ProjectsPaymentRewardDetails(props : ProjectsPaymentRewardDetailsProps) {
    const {
        isInternational,
        project,
        reward,
        value
    } = props
    const scope = isInternational ? 'projects.contributions.edit_international' : 'projects.contributions.edit'
    const editRewardUrl = `/projects/${project.project_id}/contributions/new${reward.id ? `?reward_id=${reward.id}` : ''}`
    const hasDescription = !!reward.description
    const hasDeliverDate = !!reward.deliver_at
    const hasDeliverOptions = reward && (rewardVM.hasShippingOptions(reward) || reward.shipping_options === 'presential')

    const isLongDescription = reward.description && reward.description.length > 110;
    const [ isToggledDescription, setToggledDescription ] = useState(false);
    const toogleDescription = () => setToggledDescription(!isToggledDescription)

    return (
        <>
            <div class="fontsize-smaller fontweight-semibold u-marginbottom-20">
                <I18nText scope={`${scope}.selected_reward.value`} />
            </div>
            <div class="w-clearfix">
                <div class="fontsize-larger text-success u-left">
                    <CurrencyFormat label='R$' value={value} />
                </div>
                <a href={editRewardUrl} class="alt-link fontsize-smaller u-right">
                    Editar
                </a>
            </div>
            <div class="divider u-marginbottom-10 u-margintop-10"></div>
            <div class="back-payment-info-reward">
                <div class="fontsize-smaller fontweight-semibold u-marginbottom-10">
                    <I18nText scope={`${scope}.selected_reward.reward`} />
                </div>
                <div class="fontsize-smallest fontweight-semibold">
                    {reward.title}
                </div>
                <div class={`fontsize-smallest reward-description opened fontcolor-secondary ${isLongDescription ? (isToggledDescription ? 'extended' : '') : 'extended'}`}>
                    <If condition={hasDescription}>
                        {reward.description}
                    </If>
                    <If condition={!hasDescription}>
                        <I18nText trust={true} scope={`${scope}.selected_reward.review_without_reward_html`} params={{
                            value: <CurrencyFormat label='R$' value={value} />
                        }} />
                    </If>
                </div>
                <If condition={isLongDescription}>
                    <a onclick={toogleDescription} href="javascript:void(0);" class="link-hidden link-more u-marginbottom-20">
                        <If condition={isToggledDescription}>
                            menos&nbsp;
                        </If>
                        <If condition={!isToggledDescription}>
                            mais&nbsp;
                        </If>
                        <span class={`fa fa-angle-down ${isToggledDescription ? 'reversed' : ''}`}></span>
                    </a>
                </If>
                <If condition={hasDeliverDate}>
                    <div class="fontcolor-secondary fontsize-smallest u-margintop-10">
                        <span class="fontweight-semibold">
                            Entrega prevista:&nbsp;
                            <DateFormat date={reward.deliver_at} format='MMM/YYYY' />
                        </span>
                    </div>
                </If>
                <If condition={hasDeliverOptions}>
                    <div class="fontcolor-secondary fontsize-smallest">
                        <span class="fontweight-semibold">
                            Forma de envio:&nbsp;
                            <I18nText scope={`projects.contributions.shipping_options.${reward.shipping_options}`} />
                        </span>
                    </div>
                </If>
            </div>
        </>
    )
}
