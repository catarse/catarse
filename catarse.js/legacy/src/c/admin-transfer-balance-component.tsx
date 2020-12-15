import { withHooks } from "mithril-hooks"
import h from '../h';
import { AdminTransferBalanceSuccess } from './admin-transfer-balance-success';
import { AdminTransferBalanceStart } from './admin-transfer-balance-start';
import { AdminTransferBalanceConfirm } from './admin-transfer-balance-confirm';
import { AdminTransferBalanceError } from './admin-transfer-balance-error';
import { TransferState } from './admin-transfer-balance';
export const AdminTransferBalanceComponent = withHooks<AdminTransferBalanceComponentProps>(_AdminTransferBalanceComponent)

type AdminTransferBalanceComponentProps = {
    stateView : any
}

function _AdminTransferBalanceComponent (props : AdminTransferBalanceComponentProps) {
    const {
        stateView,
     } = props

    const fromUser = stateView.item;
    const toUser = stateView.toUser();
    const transferState : TransferState = stateView.transferState();
    const fromUserBalance = stateView.fromUserBalance();

     switch(transferState) {
        case TransferState.Loading:
            return h.loader();
        case TransferState.Start:
            return (
                <AdminTransferBalanceStart
                    toUserId={stateView.receiver()}
                    transferValue={stateView.amountValue()}
                    onChangeToUserId={stateView.receiver}
                    onChangeTransferValue={stateView.amountValue}
                    fromUserBalance={fromUserBalance}
                    nextStep={() => stateView.start(stateView.receiver())} />
            )
        case TransferState.Confirm:
            return (
                <AdminTransferBalanceConfirm
                    transferValue={stateView.amountValue()}
                    fromUser={fromUser}
                    toUser={toUser}
                    submit={stateView.submit}
                    backToStart={() => stateView.transferState(TransferState.Start)} />
            )

        case TransferState.Success:
            return (<AdminTransferBalanceSuccess fromUser={fromUser} toUser={toUser} transferValue={stateView.amountValue()} />)

        case TransferState.Error:
            return (
                <AdminTransferBalanceError errorMessage={stateView.error_message()} />
            )
    }
}
