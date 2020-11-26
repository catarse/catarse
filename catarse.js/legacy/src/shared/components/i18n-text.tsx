import m from 'mithril'
import { withHooks } from 'mithril-hooks'
import { ThisWindow } from '../../entities'

declare var window : ThisWindow

export type I18nTextProps = {
    scope: string
    params?: {} & object
    trust?: boolean
}

export const I18nText = withHooks<I18nTextProps>(_I18nText)

function _I18nText({ scope, params = {}, trust = false } : I18nTextProps) {
    return (
        trust ?
            m.trust(window.I18n.t(scope, { ...params } as any))
            :
            window.I18n.t(scope, { ...params } as any)    
    )
}