import { RequestOptions } from 'mithril'
import { HttpHeaders, Body, Response, ResponseType } from '../entities'

export function setupMithrilRequestOptions(headers : HttpHeaders, body : Body, responseType : ResponseType = '') {
    const options : RequestOptions<any> = {
        headers,
        config(xhr) {
            xhr.responseType = responseType
        },
        withCredentials: true,
        extract(xhr : XMLHttpRequest) : Response {

            const headers = parseResponseHeadersToObject(xhr.getAllResponseHeaders())
            
            return {
                status: xhr.status,
                statusText: xhr.statusText,
                data: xhr.responseText,
                headers,
                toJson() : JSON {
                    return JSON.parse(xhr.responseText)
                },
                to<T>() : T {
                    return JSON.parse(xhr.responseText) as any as T
                }
            }
        }
    }

    return options
}

function parseResponseHeadersToObject(headers : string) : HttpHeaders {
    const headersLines = headers.trim().split(/[\r\n]+/)
    const headersObject = {}
    headersLines.forEach(function (line) {
        const parts = line.split(': ')
        const header = parts.shift()
        const value = parts.join(': ')
        headersObject[header] = value
    })
    return new Headers(headersObject) as HttpHeaders
}