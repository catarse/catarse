import { withHooks } from "mithril-hooks"
import { UserDetails } from "../entities"
import { I18nText } from '../shared/components/i18n-text';
export const AdminTransferBalanceSuccess = withHooks<AdminTransferBalanceSuccessProps>(_AdminTransferBalanceSuccess)

type AdminTransferBalanceSuccessProps = {
    fromUser: UserDetails
    toUser: UserDetails
    transferValue: number
 }


function _AdminTransferBalanceSuccess (props : AdminTransferBalanceSuccessProps) {
    const {
        fromUser,
        toUser,
        transferValue
     } = props

    return (
        <div id="transfer" data-ix="display-none-on-load" style="display: block;">
            <div class="fontsize-small u-marginbottom-20">
                ✅ <I18nText scope="admin.balance_transactions.view.success"/>
            </div>
            <div class="u-marginbottom-20 w-row">
                <div class="w-col w-col-3">
                    <div class="fontsize-smaller fontweight-semibold">
                        <I18nText scope="admin.balance_transactions.view.amount"/>
                    </div>
                </div>
                <div class="w-col w-col-9">
            <div class="fontsize-smaller">R$ {transferValue}</div>
                </div>
            </div>
            <div class="u-marginbottom-20 w-row">
                <div class="w-col w-col-3">
                    <div class="fontsize-smaller fontweight-semibold">
                        <I18nText scope="admin.balance_transactions.view.sender"/>
                    </div>
                </div>
                <div class="w-col w-col-9">
                <div class="fontsize-smaller fontweight-semibold">{fromUser.name}</div>
                    <div class="fontsize-smaller">(ID:&nbsp;{fromUser.id})&nbsp;
                        <a href={`/users/${fromUser.id}/edit#balance`} target="_blank" class="alt-link fontsize-smallest">
                            <I18nText scope="admin.balance_transactions.view.check_balance"/>
                        </a>
                    </div>
                </div>
            </div>
            <div class="u-marginbottom-20 w-row">
                <div class="w-col w-col-3">
                    <div class="fontsize-smaller fontweight-semibold">
                        <I18nText scope="admin.balance_transactions.view.receiver"/>
                    </div>
                </div>
                <div class="w-col w-col-9">
                    <div class="fontsize-smaller fontweight-semibold">{toUser.name}</div>
                    <div class="fontsize-smaller">(ID:&nbsp;{toUser.id})&nbsp;
                        <a href={`/users/${toUser.id}/edit#balance`} target="_blank" class="alt-link fontsize-smallest">
                            <I18nText scope="admin.balance_transactions.view.check_balance"/>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    )
}
