import h from '../../h'
import { withHooks } from 'mithril-hooks'

export type DocumentFormatProps = {
    number: string
    type: string
}

export const DocumentFormat = withHooks<DocumentFormatProps>(_DocumentFormat)

function _DocumentFormat({ number, type } : DocumentFormatProps) {
    return (
        documentFormatter(number, type)
    )
}

const documentMask = h.mask.bind(null, '999.999.999-99')
const documentCompanyMask = h.mask.bind(null, '99.999.999/9999-99')
const documentFormatter = (document_number, document_type) => document_type === 'cpf' ? documentMask(document_number) : documentCompanyMask(document_number)