import m from 'mithril'
import h from '../../h'

export type ExploreSearchFilterSelectProps = {
    onSearch(searchText : string): void
    onSelect(item : any | null): void
    isLoading(): boolean
    itemToString(item : any) : string
    mobileLabel: string
    selectedItem() : any
    noneSelected: string
    foundItems(): any[]
}

export type ExploreSearchFilterSelectState = {
    openSearchControl: {
        (newData : boolean): boolean
        toggle(): boolean
    }
}

export class ExploreSearchFilterSelect implements m.Component<ExploreSearchFilterSelectProps, ExploreSearchFilterSelectState> {
    oninit(vnode) {
        vnode.state.openSearchControl = h.RedrawToggleStream(false, true)
    }

    view({ state, attrs }) {
        const onSearch = attrs.onSearch
        const onSelect = attrs.onSelect
        const isLoading = attrs.isLoading
        const itemToString = attrs.itemToString
        const mobileLabel = attrs.mobileLabel
        const hasItemSelected = attrs.selectedItem() !== null
        const noneSelected = attrs.noneSelected
        const selectedItem = hasItemSelected ? itemToString(attrs.selectedItem()) : noneSelected
        const foundItems = attrs.foundItems() || []
        const openSearchControl = state.openSearchControl 
        const onToggleSearchBox = (event : Event) => {
            event.stopPropagation()
            openSearchControl.toggle()
            if (openSearchControl()) {
                onSearch('')
            }
        }
        const onClickToSelect = (item : any | null) => (event) => {
            event.preventDefault()
            onSelect(item)
            onToggleSearchBox(event)
        }

        return (
            <div class='explore-filter-wrapper'>
                <div onclick={onToggleSearchBox} class='explore-span-filter'>
                    <div class='explore-span-filter-name'>
                        <div class='explore-mobile-label'>
                            {mobileLabel}
                        </div>
                        <div class='inline-block'>
                            {selectedItem}
                        </div>
                    </div>
                    <div
                        class={`${hasItemSelected ? 'fa fa-times' : 'fa fa-angle-down' } inline-block`}
                        onclick={(event) => {
                            if (hasItemSelected) {
                                onSelect(null)
                                event.stopPropagation()
                                openSearchControl(false)
                            } else {
                                onToggleSearchBox(event)
                            }
                        }}
                    >    
                    </div>
                </div>
                {
                    openSearchControl() &&
                    <div class='explore-filter-select big w-clearfix' style='display: block'>
                        <a onclick={onToggleSearchBox} href='#' class='modal-close fa fa-close fa-lg w-hidden-main w-hidden-medium w-inline-block'></a>
                        <div class='w-form'>
                            <form class='position-relative'>
                                <a href='#' class='btn-search w-inline-block'>
                                    <img src='https://uploads-ssl.webflow.com/57ba58b4846cc19e60acdd5b/57ba58b4846cc19e60acdda7_lupa.png' alt='lupa' class='header-lupa'/>
                                </a>
                                <input 
                                    oncreate={(vnode) => (vnode.dom as HTMLElement)?.focus({})}
                                    oninput={(event) => onSearch(event.target.value)}
                                    onkeyup={(event) => onSearch(event.target.value)}
                                    type='text'
                                    placeholder='Pesquise por cidade ou estado'
                                    class='text-field positive city-search w-input'
                                />
                                <div class='table-outer search-cities-pre-result'>
                                    {
                                        isLoading() ?
                                            h.loader()
                                            :
                                            foundItems.length === 0 ?
                                                <div class='table-row fontsize-smallest fontcolor-secondary'>
                                                    <a 
                                                        href='#'
                                                        class='fontsize-smallest link-hidden-light'
                                                        onclick={onClickToSelect(null)} 
                                                    >
                                                        {noneSelected}
                                                    </a>
                                                </div>
                                                :
                                                foundItems.map(item => (
                                                    <div class='table-row fontsize-smallest fontcolor-secondary'>
                                                        <a 
                                                            href='#'
                                                            class='fontsize-smallest link-hidden-light'
                                                            onclick={onClickToSelect(item)}
                                                        >
                                                            {itemToString(item)}
                                                        </a>
                                                    </div>
                                                ))
                                    }
                                </div>
                            </form>
                        </div>
                    </div>
                }
            </div>
        )
    }
}
