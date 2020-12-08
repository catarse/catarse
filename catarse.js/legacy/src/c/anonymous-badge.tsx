import m from 'mithril'
import { withHooks } from 'mithril-hooks'

export default withHooks<AnonymousBadgeProps>(AnonymousBadge)

type AnonymousBadgeProps = {
    text: m.Children
    isAnonymous: boolean
}

function AnonymousBadge({text, isAnonymous} : AnonymousBadgeProps) {
    if (isAnonymous) {
        return (
            <span class="fa fa-eye-slash fontcolor-secondary">
                <span class="fontcolor-secondary" style="font-size:11px;">
                    {text}
                </span>
            </span>
        )
    }
    else {
        return <div />
    }
}
