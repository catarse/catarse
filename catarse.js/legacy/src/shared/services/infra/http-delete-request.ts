import { HttpHeaders, Response } from './entities'

export type HttpDeleteRequest = (url : string, headers : HttpHeaders) => Promise<Response>