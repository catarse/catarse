// import Postgrest from 'mithril-postgrest';
const testToken = "test_token";
const nContributions = 20;
const apiMeta = document.createElement('meta');
const apiPrefix = 'https://api.catarse.me'
apiMeta.content = apiPrefix;
apiMeta.name = 'api-host';
document.getElementsByTagName('head')[0].appendChild(apiMeta);

const ApiMomentsMeta = document.createElement('meta');
ApiMomentsMeta.content = 'https://api-moments.catarse.me';
ApiMomentsMeta.name = 'api-moments-host';
document.getElementsByTagName('head')[0].appendChild(ApiMomentsMeta);

const commonPaymentApiMeta = document.createElement('meta');
commonPaymentApiMeta.content = 'https://payment.common.io';
commonPaymentApiMeta.name = 'common-payment-api-host';
document.getElementsByTagName('head')[0].appendChild(commonPaymentApiMeta);

const commonProjectApiMeta = document.createElement('meta');
commonProjectApiMeta.content = 'https://project.common.io';
commonProjectApiMeta.name = 'common-project-api-host';
document.getElementsByTagName('head')[0].appendChild(commonProjectApiMeta);

const commonCommunityApiMeta = document.createElement('meta');
commonCommunityApiMeta.content = 'https://community.common.io';
commonCommunityApiMeta.name = 'common-community-api-host';
document.getElementsByTagName('head')[0].appendChild(commonCommunityApiMeta);

const commonAnalyticsApiMeta = document.createElement('meta');
commonAnalyticsApiMeta.content = 'https://analytics.common.io';
commonAnalyticsApiMeta.name = 'common-analytics-api-host';
document.getElementsByTagName('head')[0].appendChild(commonAnalyticsApiMeta);

const commonNotificationApiMeta = document.createElement('meta');
commonNotificationApiMeta.content = 'https://notification.common.io';
commonNotificationApiMeta.name = 'common-notification-api-host';
document.getElementsByTagName('head')[0].appendChild(commonNotificationApiMeta);

const commonRecommenderApiMeta = document.createElement('meta');
commonRecommenderApiMeta.content = 'https://recommender.common.io';
commonRecommenderApiMeta.name = 'common-recommender-api-host';
document.getElementsByTagName('head')[0].appendChild(commonRecommenderApiMeta);

const commonProxyApiMeta = document.createElement('meta');
commonProxyApiMeta.content = 'https://proxy.common.io';
commonProxyApiMeta.name = 'common-proxy-api-host';
document.getElementsByTagName('head')[0].appendChild(commonProxyApiMeta);

const mockEndpoint = function(endpoint, result){
  return jasmine.Ajax.stubRequest(
    new RegExp('(' + apiPrefix + '\/' + endpoint + ')(.*)')
  ).andReturn({
    'responseText' : JSON.stringify(result)
  });
};

beforeAll(function() {
  jasmine.Ajax.install();

  //API token stub
  jasmine.Ajax.stubRequest('/api_token').andReturn({
    'responseText' : '{"token": "' + testToken + '"}'
  });

  jasmine.Ajax.stubRequest('/test').andReturn({
    'responseText' : '{"object": "responseOK"}'
  });


});

afterAll(function() {
  jasmine.Ajax.uninstall();
});
