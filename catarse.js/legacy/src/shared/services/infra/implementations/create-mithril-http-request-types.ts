import m from 'mithril'
import { Middleware, Response, HttpHeaders, Body, ResponseType } from '../entities'
import { HttpDeleteRequest } from '../http-delete-request'
import { HttpPutRequest } from '../http-put-request'
import { HttpPostRequest } from '../http-post-request'
import { HttpGetRequest } from '../http-get-request'
import { setupMithrilRequestOptions } from './setup-mithril-request-options'

export function createMithrilHttpRequestHandlers(middlewares : Middleware[]) {
    return {
        put: createMithrilHttpRequestHandler(middlewares, 'PUT') as HttpPutRequest,
        get: createMithrilHttpRequestHandler(middlewares, 'GET') as HttpGetRequest,
        post: createMithrilHttpRequestHandler(middlewares, 'POST') as HttpPostRequest,
        delete: createMithrilHttpRequestHandler(middlewares, 'DELETE') as HttpDeleteRequest,
    }
}

function createMithrilHttpRequestHandler(middlewares : Middleware[], method : string) {
    return async <T>(url: string, headers: HttpHeaders, body: Body, responseType : ResponseType = '') : Promise<Response> => {
        for (const middleware of middlewares) {
            middleware(url, headers, body)
        }

        const options = setupMithrilRequestOptions(headers, body, responseType)
        options.method = method.toLowerCase()
        if (method === 'GET' || method === 'DELETE') {
            delete options['body']
        } else {
            options.useBody = true
            options['data'] = body
        }
        
        return await m.request(url, options)
    }
}