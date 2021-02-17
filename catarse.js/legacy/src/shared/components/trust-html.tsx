import m from 'mithril'
import { withHooks } from 'mithril-hooks'

export type TrustHtmlProps = {
    html: string;
}

export const TrustHtml = withHooks<TrustHtmlProps>(_TrustHtml)

function _TrustHtml({ html } : TrustHtmlProps) {
    return m.trust(html)
}
