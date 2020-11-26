import { withHooks } from 'mithril-hooks'
import h from '../../h'

export type CurrencyFormatProps = {
    label?: string
    value: number
    precision?: number
}

export const CurrencyFormat = withHooks<CurrencyFormatProps>(_CurrencyFormat)

function _CurrencyFormat({ label, value, precision = 2} : CurrencyFormatProps) {
    return (
        `${label ? `${label} ` : ''}${formatNumber(value, precision)}`
    )
}

function formatNumber(value : number | string, precision : number) : string {
    return h.formatNumber(Number(value), precision, 3)
}