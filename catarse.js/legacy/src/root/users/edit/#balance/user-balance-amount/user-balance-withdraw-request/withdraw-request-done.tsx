import { withHooks } from 'mithril-hooks'
import { I18nText } from '../../../../../../shared/components/i18n-text'

export const WithdrawRequestDone = withHooks(_WithdrawRequestDone)

function _WithdrawRequestDone() {
    return (
        <div id='withdraw-request-done'>
            <div class='modal-dialog-header'>
                <div class='fontsize-large u-text-center'>
                    <I18nText scope='users.balance.withdraw' />
                </div>
            </div>
            <div class='modal-dialog-content u-text-center'>
                <div class='fa fa-check-circle fa-5x text-success u-marginbottom-40'></div>
                <p class='fontsize-large'>
                    <I18nText scope='users.balance.success_message' />
                </p>
            </div>
        </div>
    )
}