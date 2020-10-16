import m from 'mithril';
import prop from 'mithril/stream';
import h from '../../h';
import { ThisWindow } from '../../@types/window';

declare var window : ThisWindow

export type ExploreMobileSearchAttrs = {
    action?: string
    method?: string
}

export type ExploreMobileSearchState = {
    searchParam(data? : string): string
}

export default class ExploreMobileSearch implements m.Component {
    
    oninit({ attrs, state } : m.Vnode<ExploreMobileSearchAttrs, ExploreMobileSearchState>) {
        state.searchParam = prop('')
    }

    view({ attrs, state } : m.Vnode<ExploreMobileSearchAttrs, ExploreMobileSearchState>) {
        const action = attrs.action || `/${window.I18n.locale}/explore?ref=ctrse_explore_pgsearch&filter=all`
        const method = attrs.method || 'GET'
        const searchParam = state.searchParam

        return (
            <div id='#search' class='w-hidden-main w-hidden-medium w-row'>
                <div class='w-col w-col-11'>
                    <div class='header-search'>
                        <div class='w-row'>
                            <div class='w-col w-col-10 w-col-small-10 w-col-tiny-10'>
                                <div class='w-form'>
                                    <form onsubmit={(event : Event) => {
                                        event.preventDefault()
                                        const url = `/${window.I18n.locale}/explore?ref=ctrse_header&utf8=✓&filter=all&pg_search=${searchParam()}`
                                        m.route.set(url)
                                        searchParam('')
                                        h.redraw()
                                    }} id='search-form-id' action={action} method={method}>
                                        <input value={searchParam()} oninput={(event) => searchParam(event.target.value)} id='pg_search_inside' type='text' name='pg_search' placeholder='Busque projetos' class='w-input text-field negative prefix'/>
                                        <input type='hidden' name='filter' value='all' />
                                    </form>
                                </div>
                            </div>

                            <div class='w-col w-col-2 w-col-small-2 w-col-tiny-2'>
                                <input value='' type='submit' alt='Lupa' form='search-form-id' class='btn btn-attached postfix btn-dark w-inline-block' style='background-repeat: no-repeat; background-position: center; background-image: url(/assets/catarse_bootstrap/lupa.png)'/>
                            </div>
                        </div>
                    </div>
                </div>

                <div class='w-col w-col-1'></div>
            </div>
        )
    }
}