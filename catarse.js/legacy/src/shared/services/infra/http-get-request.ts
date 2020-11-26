import { HttpHeaders, Response } from './entities'

export type HttpGetRequest = (url : string, headers : HttpHeaders) => Promise<Response>