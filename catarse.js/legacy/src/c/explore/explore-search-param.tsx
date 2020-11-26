import m from 'mithril'

export type ExploreSearchParamAttrs = {
    mobileLabel: string
    searchParam: string
    onClose(): void
}

export class ExploreSearchParam implements m.Component {
    view({ attrs } : m.Vnode<ExploreSearchParamAttrs>) {

        const mobileLabel = attrs.mobileLabel
        const searchParam = attrs.searchParam
        const onClose = attrs.onClose

        return (
            <div class='explore-filter-wrapper'>
                <div class='explore-span-filter'>
                    <div class='explore-span-filter-name'>
                        <div class='explore-mobile-label'>
                            {mobileLabel}
                        </div>
                        <div class='inline-block'>
                            {searchParam}
                        </div>
                    </div>

                    <div onclick={onClose} class='inline-block far fa-times'></div>
                </div>
            </div>
        )
    }
}