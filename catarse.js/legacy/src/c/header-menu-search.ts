import m from 'mithril'
import prop from 'mithril/stream'
import h from '../h'
import { ThisWindow } from '../entities/window'
import { HTMLInputEvent } from '../entities/event-target'

declare var window : ThisWindow

export type HeaderMenuSearchAttrs = {

}

export type HeaderMenuSearchState = {
    searchParam: prop<string>
    formElement: HTMLFormElement
}

export default class HeaderMenuSearch implements m.Component {
    
    oninit({state} : m.Vnode<HeaderMenuSearchAttrs, HeaderMenuSearchState>) {
        state.searchParam = prop('')
        state.formElement = null
    }

    view({state} : m.Vnode<HeaderMenuSearchAttrs, HeaderMenuSearchState>) {
        
        const searchParam = state.searchParam

        return m('span#menu-search', [
            m('.w-form.w-hidden-small.w-hidden-tiny.header-search[id="discover-form-wrapper"]', [
                m(`form.discover-form[accept-charset="UTF-8"][action="/${window.I18n.locale}/explore?ref=ctrse_header"][id="search-form"][method="get"]`, {
                    oncreate(vnode) {
                        state.formElement = vnode.dom as HTMLFormElement
                    },
                    onsubmit(event : Event) {
                        event.preventDefault()
                        const url = `/${window.I18n.locale}/explore?ref=ctrse_header&utf8=✓&filter=all&pg_search=${searchParam()}`
                        m.route.set(url)
                        searchParam('')
                        h.redraw()
                    }
                }, [
                    m('div', { style: { display: 'none' } }, [
                        m('input[name="utf8"][type="hidden"][value="✓"]'),
                        m('input[name="filter"][type="hidden"][value="all"]'),
                    ]),
                    m('input.w-input.text-field.prefix.search-input[autocomplete="off"][id="pg_search"][name="pg_search"][placeholder="Busque projetos"][type="text"]', {
                        value: searchParam(),
                        oninput(event : HTMLInputEvent) {
                            searchParam(event.target.value)
                        }
                    })
                ]),
                m(`.search-pre-result.w-hidden[data-searchpath="/${window.I18n.locale}/auto_complete_projects"]`, [
                    m('.result',
                        m('.u-text-center',
                            m('img[alt="Loader"][src="/assets/catarse_bootstrap/loader.gif"]')
                        )
                    ),
                    m('a.btn.btn-small.btn-terciary.see-more-projects[href="javascript:void(0);"]', ' ver todos')
                ])
            ]),
            m('a.w-inline-block.w-hidden-small.w-hidden-tiny.btn.btn-dark.btn-attached.postfix[href="javascript:void(0);"][id="pg_search_submit"]', { 
                onclick() { 
                    if (state.formElement) {
                        state.formElement.submit()
                    }    
                }
            },
                m('img.header-lupa[alt="Lupa"][data-pin-nopin="true"][src="/assets/catarse_bootstrap/lupa.png"]')
            )
        ])
    }
}