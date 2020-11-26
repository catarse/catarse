import { Body } from './body'
import { HttpHeaders } from './headers'

export type Response = {
    status: number
    statusText: string
    headers: HttpHeaders
    data: Body
    toJson() : JSON
    to<DataType>() : DataType
}

export type ResponseType = '' | 'arraybuffer' | 'blob' | 'document' | 'json' | 'text'