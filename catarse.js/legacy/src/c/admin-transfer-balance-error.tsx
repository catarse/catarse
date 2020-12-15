import { withHooks } from "mithril-hooks"
import { I18nText } from '../shared/components/i18n-text';
export const AdminTransferBalanceError = withHooks<AdminTransferBalanceErrorProps>(_AdminTransferBalanceError)

type AdminTransferBalanceErrorProps = {
    errorMessage(): void
 }

function _AdminTransferBalanceError (props : AdminTransferBalanceErrorProps) {
    const {
        errorMessage
     } = props

    return (
        <>
            <div class="w-form-error" style="display:block;">
                <p><I18nText scope="admin.balance_transactions.view.error"/></p>
                <p class="card card-terciary u-radius">{errorMessage}</p>
            </div>
        </>
    )
}
