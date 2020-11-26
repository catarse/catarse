import { Bank } from '../../controllers/use-cases/entities'
import { withHooks } from 'mithril-hooks'

export type UserBankSearchListProps = {
    banks: Bank[]
    onSelect(bank : Bank): void
}

export const UserBankSearchList = withHooks<UserBankSearchListProps>(_UserBankSearchList)

function _UserBankSearchList({ banks, onSelect } : UserBankSearchListProps) {
    return (
        <div id='bank_search_list' class='w-row'>
            <div class='w-col w-col-12'>
                <div style='height: 395px;' data-ix='height-0-on-load' class='select-bank-list'>
                    <div class='card card-terciary'>
                        <div class='fontsize-small fontweight-semibold u-marginbottom-10 u-text-center'>
                            Selecione o seu banco abaixo
                        </div>
                        <div class='fontsize-smaller'>
                            <div class='w-row card card-secondary fontweight-semibold'>
                                <div class='w-col w-col-3 w-col-small-3 w-col-tiny-3'>
                                    <div>
                                        Número
                                    </div>
                                </div>
                                <div class='w-col w-col-9 w-col-small-9 w-col-tiny-9'>
                                    <div>
                                        Nome
                                    </div>
                                </div>
                            </div>
                            {
                                !!banks && banks.length &&
                                banks.map(bank => (
                                    <div class='w-row card fontsize-smallest'>
                                        <div class='w-col w-col-3 w-col-small-3 w-col-tiny-3'>
                                            <a onclick={() => onSelect(bank)} href='javascript:void(0)' data-id={bank.id} data-code={bank.code} class='link-hidden bank-resource-link'>
                                                {bank.code}
                                            </a>
                                        </div>
                                        <div class='w-col w-col-9 w-col-small-9 w-col-tiny-9'>
                                            <a onclick={() => onSelect(bank)} href='javascript:void(0)' data-id={bank.id} data-code={bank.code} class='link-hidden bank-resource-link'>
                                                {bank.code} . {bank.name}
                                            </a>
                                        </div>                                    
                                    </div>
                                ))
                            }
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}