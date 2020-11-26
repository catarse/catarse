import m from 'mithril'
import h from '../../h'

export type InputCurrencyAttrs = {
    placeholder: string
    value: number
    onValueChange(newValue : number): void
    class: string
    onfocus(event : Event): void
    onblur(event : Event): void
}

export class InputCurrency implements m.Component {
    view({attrs} : m.Vnode<InputCurrencyAttrs>) {

        const placeholder = attrs.placeholder
        const value = attrs.value
        const onValueChange = attrs.onValueChange
        const onfocus = attrs.onfocus
        const onblur = attrs.onblur

        return (
            <input
                value={numberToCurrency(value)}
                type='text'
                placeholder={placeholder}
                oninput={(event : Event) => {
                    const element = event.target as HTMLInputElement
                    onValueChange(currencyToNumber(element.value))
                }}
                onblur={onblur}
                onfocus={onfocus}
                class={`back-reward-input-reward w-input ${attrs.class}`} />
        )
    }
}

function numberToCurrency(amount : number) : string {
    return Intl.NumberFormat('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2}).format(amount)
}

function currencyToNumber(currency : string) : number {
    const currencyOnlyNumbers = currency.replace(/\D*/g, '')
    const integerPart = currencyOnlyNumbers.slice(0, currencyOnlyNumbers.length - 2)
    const decimalPart = currencyOnlyNumbers.slice(currencyOnlyNumbers.length - 2, currencyOnlyNumbers.length)
    return Number(`${integerPart}.${decimalPart}`)
}