import { Body, HttpHeaders, Response } from './entities'

export type HttpPostRequest = (url : string, headers : HttpHeaders, body : Body) => Promise<Response>