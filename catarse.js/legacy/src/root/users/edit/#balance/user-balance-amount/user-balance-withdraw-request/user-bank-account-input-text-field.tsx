import { withHooks } from 'mithril-hooks'
import { HTMLInputEvent } from '../../../../../../entities'
import { InlineErrors } from '../../../../../../c/inline-errors'

export type UserBankAccountInputTextFieldProps = {
    id?: string
    className: string
    labelText: string
    required?: boolean
    errors: string[]
    value: string
    onChange(value : string): void
}

export const UserBankAccountInputTextField = withHooks<UserBankAccountInputTextFieldProps>(_UserBankAccountInputTextField)

function _UserBankAccountInputTextField(props : UserBankAccountInputTextFieldProps) {
    
    const {
        id = '',
        className,
        labelText,
        required = true,
        errors,
        value,
        onChange,
    } = props

    const requiredOrOptionalClass = required ? 'required' : 'optional'
    const errorClass = errors?.length ? 'error' : ''

    return (
        <div id={id} class={className}>
            <label  for={id} class={`${requiredOrOptionalClass} text field-label field-label fontweight-semibold force-text-dark fontsize-smaller`}>
                {labelText}
            </label>
            <input 
                type='text'
                value={value}
                onchange={(event : HTMLInputEvent) => {
                    onChange(event.target.value)
                }}
                class={`${requiredOrOptionalClass} ${errorClass} string w-input text-field positive`} 
                />
            <InlineErrors messages={errors} />
        </div>
    )

}