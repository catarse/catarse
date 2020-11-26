import { Body, HttpHeaders, Response, ResponseType } from './entities'

export type HttpPutRequest = <T>(url : string, headers : HttpHeaders, body : Body | T, responseType? : ResponseType) => Promise<Response>