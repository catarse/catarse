import { Body, HttpHeaders, Response } from './entities'

export type HttpPostRequest = <R, T = Body>(url : string, headers : HttpHeaders, body : T) => Promise<Response<R>>
