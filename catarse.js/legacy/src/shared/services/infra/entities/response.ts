import { Body } from './body'
import { HttpHeaders } from './headers'

export type Response<DataType = Body> = {
    status: number
    statusText: string
    headers: HttpHeaders
    data: DataType
    toJson() : JSON
    to<DataType>() : DataType
}

export type ResponseType = '' | 'arraybuffer' | 'blob' | 'document' | 'json' | 'text'
