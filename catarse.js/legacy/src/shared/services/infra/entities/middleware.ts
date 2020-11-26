import { Body, HttpHeaders, Response } from '.'

export type Middleware = (url : string, headers : HttpHeaders, body? : Body) => void