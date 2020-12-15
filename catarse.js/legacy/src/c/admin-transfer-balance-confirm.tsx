import { withHooks } from "mithril-hooks"
import { UserDetails } from "../entities"
import { I18nText } from '../shared/components/i18n-text';
export const AdminTransferBalanceConfirm = withHooks<AdminTransferBalanceConfirmProps>(_AdminTransferBalanceConfirm)

type AdminTransferBalanceConfirmProps = {
    transferValue: number
    fromUser: UserDetails
    toUser: UserDetails
    submit() : void
    backToStart() : void
 }

function _AdminTransferBalanceConfirm (props : AdminTransferBalanceConfirmProps) {
    const {
        transferValue,
        fromUser,
        toUser,
        submit,
        backToStart,
     } = props

    return (
        <>
            <div class="fontsize-small u-marginbottom-20">
                🔍 <I18nText scope="admin.balance_transactions.view.data_confirmation"/>
            </div>
            <div class="u-marginbottom-20 w-row">
                <div class="w-col w-col-3">
                    <div class="fontsize-smaller fontweight-semibold">
                        <I18nText scope="admin.balance_transactions.view.amount"/>
                    </div>
                </div>
                <div class="w-col w-col-9">
                    <div class="fontsize-smaller">R${transferValue}</div>
                </div>
            </div>
            <div class="u-marginbottom-20 w-row">
                <div class="w-col w-col-3">
                    <div class="fontsize-smaller fontweight-semibold">
                        <I18nText scope="admin.balance_transactions.view.sender"/>
                    </div>
                </div>
                <div class="w-col w-col-9">
                    <div class="fontsize-smaller fontweight-semibold">
                        {fromUser.name}
                    </div>
                    <div class="fontsize-smaller">(ID:&nbsp;{fromUser.id})</div>
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
                    <div class="fontsize-smaller">(ID:&nbsp;{toUser.id})</div>
                </div>
            </div>
            <div class="w-form">
                <form id="email-form-4" name="email-form-4" data-name="Email Form 4">
                    <div class="w-row">
                        <div onclick={submit} class="w-col w-col-6">
                            <button class="btn btn-small">
                                <I18nText scope="admin.balance_transactions.view.confirm"/>
                            </button>
                        </div>
                        <div onclick={() => backToStart} class="w-col w-col-6">
                            <button class="btn btn-small btn-terciary">
                                <I18nText scope="admin.balance_transactions.view.back"/>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </>
    )
}
