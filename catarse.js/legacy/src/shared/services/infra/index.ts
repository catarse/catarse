import { HttpDeleteRequest } from './http-delete-request'
import { HttpPutRequest } from './http-put-request'
import { HttpPostRequest } from './http-post-request'
import { HttpGetRequest } from './http-get-request'

import { createMithrilHttpRequestHandlers } from './implementations/create-mithril-http-request-types'
import { setCSRFHeaderFromMetaTags } from './middlewares/set-csrf-header-from-meta-tags'

const requestHandlers = createMithrilHttpRequestHandlers([setCSRFHeaderFromMetaTags])
export const httpPutRequest : HttpPutRequest = requestHandlers.put
export const httpGetRequest : HttpGetRequest = requestHandlers.get
export const httpPostRequest : HttpPostRequest = requestHandlers.post
export const httpDeleteRequest : HttpDeleteRequest = requestHandlers.delete

export { HttpGetRequest, HttpPostRequest, HttpDeleteRequest, HttpPutRequest }