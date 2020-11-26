import m from 'mithril'
import { withHooks } from 'mithril-hooks'

export const Loader = withHooks(_Loader)

function _Loader() {
    return (
        <div class='u-text-center u-margintop-30 u-marginbottom-30'>
            <img alt='Loader' src='https://s3.amazonaws.com/catarse.files/loader.gif'/>
        </div>
    )
}