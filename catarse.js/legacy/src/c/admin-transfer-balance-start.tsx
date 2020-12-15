import { withHooks } from "mithril-hooks"
import { HTMLInputEvent } from "../entities"
import { I18nText } from '../shared/components/i18n-text';
export const AdminTransferBalanceStart = withHooks<AdminTransferBalanceStartProps>(_AdminTransferBalanceStart)

type AdminTransferBalanceStartProps = {
    toUserId: number
    transferValue: number
    fromUserBalance: number
    onChangeToUserId(userId : number) : void
    onChangeTransferValue(transferValue : number) : void
    nextStep() : void
 }

function _AdminTransferBalanceStart (props : AdminTransferBalanceStartProps) {
    const {
        toUserId,
        transferValue,
        fromUserBalance,
        onChangeToUserId,
        onChangeTransferValue,
        nextStep
     } = props

    return (
        <div id="transfer" data-ix="display-none-on-load" style="display: block;">
            <div class="fontsize-small text-success fontweight-semibold u-marginbottom-20">
                <I18nText scope="admin.balance_transactions.view.current_balance"/> R$ {fromUserBalance}
            </div>
            <div class="w-form">
                <form onsubmit={(event : Event) => event.preventDefault()} id="email-form-4" name="email-form-4" data-name="Email Form 4">
                    <div class="u-marginbottom-20">
                        <label for="name"><I18nText scope="admin.balance_transactions.view.receiver_id"/></label>
                        <input value={toUserId} onchange={(event : HTMLInputEvent) => onChangeToUserId(Number(event.target.value))}
                            type="text" id="name" name="name" data-name="Name" placeholder="ex: 129908" class="text-field w-input"/>
                    </div>
                    <div class="u-marginbottom-20">
                        <label for="transferValue"><I18nText scope="admin.balance_transactions.view.amount"/></label>
                        <input value={transferValue} onchange={(event : HTMLInputEvent) => onChangeTransferValue(Number(event.target.value))}
                            type="number" id="transferValue"
                            name="transferValue" data-name="transferValue" placeholder="ex: 10.50"
                            class="text-field w-input"/>

                    </div>

                    <button onclick={nextStep} type="submit" class="btn btn-small w-button">
                        <I18nText scope="admin.balance_transactions.view.next_step"/>
                    </button>
                </form>
            </div>
        </div>
    )
}
