import m from 'mithril'
import Postgrest from 'mithril-postgrest'
import { default as jwt_decode } from 'jwt-decode'

const platformTokenMeta = document.querySelector('[name="common-platform-token"]')
const platformToken = platformTokenMeta ? platformTokenMeta.getAttribute('content') : null
const commonRequestHeader = { 'Platform-Code' : platformToken }

const apiInit = (api, apiMeta, authUrl, globalHeader = {}) => {
    api.init(apiMeta.getAttribute('content'), { method: 'GET', url: authUrl }, globalHeader, isTokenExpired)
}

const catarse = new Postgrest(m)
const catarseApiMeta = document.querySelector('[name="api-host"]')
apiInit(catarse, catarseApiMeta, '/api_token')

const catarseMoments = new Postgrest(m)
const catarseApiMomentsMeta = document.querySelector('[name="api-moments-host"]')
apiInit(catarseMoments, catarseApiMomentsMeta, '/api_token')

const commonPayment = new Postgrest(m)
const commonPaymentApiMeta = document.querySelector('[name="common-payment-api-host"]')
apiInit(commonPayment, commonPaymentApiMeta, '/api_token/common', commonRequestHeader)

const commonProject = new Postgrest(m)
const commonProjectApiMeta = document.querySelector('[name="common-project-api-host"]')
apiInit(commonProject, commonProjectApiMeta, '/api_token/common', commonRequestHeader)

const commonAnalytics = new Postgrest(m)
const commonAnalyticsApiMeta = document.querySelector('[name="common-analytics-api-host"]')
apiInit(commonAnalytics, commonAnalyticsApiMeta, '/api_token/common', commonRequestHeader)

const commonNotification = new Postgrest(m)
const commonNotificationApiMeta = document.querySelector('[name="common-notification-api-host"]')
apiInit(commonNotification, commonNotificationApiMeta, '/api_token/common', commonRequestHeader)

// not a postgrest instance, but pretend it is to get free pagination
const commonRecommender = new Postgrest(m)
const commonRecommenderApiMeta = document.querySelector('[name="common-recommender-api-host"]')
apiInit(commonRecommender, commonRecommenderApiMeta, '/api_token/common', commonRequestHeader)

const commonCommunity = new Postgrest(m)
const commonCommunityApiMeta = document.querySelector('[name="common-community-api-host"]')
apiInit(commonCommunity, commonCommunityApiMeta, '/api_token/common', commonRequestHeader)

const commonProxy = new Postgrest(m)
const commonProxyApiMeta = document.querySelector('[name="common-proxy-api-host"]')
apiInit(commonProxy, commonProxyApiMeta, '/api_token/common_proxy', commonRequestHeader)

async function isTokenExpired(token : string) : Promise<boolean> {
    if (token) {
        try {
            const decoded = jwt_decode<{ exp: number }>(token)
            const expirationTimestamp = Number(decoded.exp) * 1000
            const expirationTimestampMinus10Min = expirationTimestamp - _10MinutesInMs
            return Date.now() >= expirationTimestampMinus10Min
        } catch(error) {
            return false
        }
    }
    return false
}

const _10MinutesInMs = 10 * 60 * 1000

export {
    catarse, 
    catarseMoments, 
    commonPayment, 
    commonProject, 
    commonAnalytics, 
    commonNotification, 
    commonRecommender, 
    commonCommunity, 
    commonProxy 
}