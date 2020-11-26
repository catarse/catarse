import { withHooks } from 'mithril-hooks'
import { InlineErrors } from '../../../../../../c/inline-errors'
import { HTMLSelectEvent } from '../../../../../../entities'

export type UserBankAccountSelectValueProps = {
    id?: string
    className: string
    labelText: string
    options: Option[]
    value: string
    onChange(value : string): void
    errors: string[]
}

type Option = {
    label: string
    value: string
}

export const UserBankAccountSelectValue = withHooks<UserBankAccountSelectValueProps>(_UserBankAccountSelectValue)

function _UserBankAccountSelectValue(props : UserBankAccountSelectValueProps) {

    const {
        id = '',
        className,
        labelText,
        errors,
        options,
        value,
        onChange,
    } = props

    const errorClass = errors?.length ? 'error' : ''

    return (
        <div id={id} class={className}>
            <label class='field-label fontweight-semibold fontsize-smaller'>
                {labelText}
            </label>
            <div class={`input select required`}>
                <select
                    class={`${errorClass} select required w-input text-field bank-select positive`}
                    value={value}
                    onchange={(event : HTMLSelectEvent) => onChange(event.target.value)}>
                    {options?.map((option, index) => (
                        <option key={index} selected={option.value === value} value={option.value}>
                            {option.label}
                        </option>
                    ))}
                </select>
                <InlineErrors messages={errors} />
            </div>
        </div>
    )
}