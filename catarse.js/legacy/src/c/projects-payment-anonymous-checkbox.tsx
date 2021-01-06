import { withHooks } from "mithril-hooks"
import { CatarseAnalyticsType } from "../entities"
import { I18nText } from "../shared/components/i18n-text"
import { If } from "../shared/components/if"

export default withHooks<AnonymousCheckboxProps>(AnonymousCheckbox)

declare var CatarseAnalytics : CatarseAnalyticsType

type AnonymousCheckboxProps = {
    isAnonymous: boolean
    onChange(): void
    isInternational: boolean
}

function AnonymousCheckbox(props : AnonymousCheckboxProps) {
    const {
        isAnonymous,
        onChange,
        isInternational
    } = props

    const onclick = () => CatarseAnalytics.event({
        cat: 'contribution_finish',
        act: 'contribution_anonymous_change',
    })

    const scope = isInternational ? 'projects.contributions.edit_international' : 'projects.contributions.edit'

    return (
        <div class="w-row">
            <div class="w-checkbox w-clearfix">
                <input
                    onclick={onclick}
                    onchange={onChange}
                    checked={isAnonymous}
                    type="checkbox"
                    class="w-checkbox-input"
                    id="anonymous"
                    name="anonymous"
                />
                <label htmlFor="anonymous" class="w-form-label fontsize-smallest">
                    <I18nText scope={`${scope}.fields.anonymous`} />
                </label>
            </div>
            <If condition={isAnonymous}>
                <div class="card card-message u-radius zindex-10 fontsize-smallest">
                    <div>
                        <span class="fontweight-bold">
                            <I18nText scope={`${scope}.anonymous_confirmation_title`} />
                            <br/>
                        </span>
                        <br/>
                        <I18nText scope={`${scope}.anonymous_confirmation`} />
                    </div>
                </div>
            </If>
        </div>
    )
}
