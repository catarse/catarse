import { withHooks } from 'mithril-hooks'
import h from '../../h'

export type DateFormatProps = {
    date: string
    format: string
}

export const DateFormat = withHooks<DateFormatProps>(_DateFormat)

function _DateFormat({ date, format } : DateFormatProps) {
    return (
        h.momentify(date, format)
    )
}