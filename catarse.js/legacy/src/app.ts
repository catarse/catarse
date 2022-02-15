import m from 'mithril';
import h from './h';
import _ from 'underscore';
import c from './c';
import Chart from 'chart.js';
import { Wrap } from './wrap';
import { AdminWrap } from './admin-wrap';

m.originalTrust = m.trust;
m.trust = (text) => h.trust(text);

(function () {

    window.m = m;
    h.SentryInitSDK();

    history.pushState = h.attachEventsToHistory('pushState');
    history.replaceState = h.attachEventsToHistory('replaceState');
    /// Setup an AUTO-SCROLL TOP when change route
    const pushState = history.pushState;
    history.pushState = function () {
        if (typeof window.history.onpushstate == 'function') {
            window.history.onpushstate.apply(history, arguments);
        }
        pushState.apply(history, arguments);
        h.scrollTop();
    };

    Chart.defaults.global.responsive = true;
    Chart.defaults.global.responsive = false;
    Chart.defaults.global.scaleFontFamily = 'proxima-nova';

    // NOTE: comment when need to use multilanguage i18n support
    window.I18n.defaultLocale = 'pt';
    window.I18n.locale = 'pt';

    const adminRoot = document.getElementById('new-admin');

    if (adminRoot) {
        m.route.prefix('#');

        m.route(adminRoot, '/', {
            '/': AdminWrap(c.root.AdminContributions, { root: adminRoot, menuTransparency: false, hideFooter: true }),
            '/home-banners': AdminWrap(c.root.AdminHomeBanners, { menuTransparency: false, hideFooter: true }),
            '/users': AdminWrap(c.root.AdminUsers, { menuTransparency: false, hideFooter: true }),
            '/subscriptions': AdminWrap(c.root.AdminSubscriptions, { menuTransparency: false, hideFooter: true }),
            '/projects': AdminWrap(c.root.AdminProjects, { menuTransparency: false, hideFooter: true }),
            '/notifications': AdminWrap(c.root.AdminNotifications, { menuTransparency: false, hideFooter: true }),
            '/balance-transfers': AdminWrap(c.root.AdminBalanceTranfers, { menuTransparency: false, hideFooter: true }),
        });
    }

    const app = document.getElementById('application'),
        body = document.body;

    const urlWithLocale = function (url) {
        return `/${window.I18n.locale}${url}`;
    };

    if (app) {
        const rootEl = app,
            isUserProfile =
                body.getAttribute('data-controller-name') == 'users' &&
                body.getAttribute('data-action') == 'show' &&
                app.getAttribute('data-hassubdomain') == 'true';

        m.route.prefix('');

        /**
         * Contribution/Subscription flow.
         *
         * ProjectShow ->
         *      contribution: ProjectsContribution -> ProjectsPayment -> ThankYou
         *      subscription: ProjectsSubscriptionContribution -> ProjectsSubscriptionCheckout -> ProjectsSubscriptionThankYou
         */
        tryMountingRoutes();
        let mountingRetries = 3;
        function tryMountingRoutes() {
            try {
                mountRoutes();
                mountingRetries = 3;
            } catch (error) {
                if (mountingRetries > 0) {
                    h.captureException(error);
                    app.innerHTML = '';
                    // gets out of recursion
                    setTimeout(tryMountingRoutes);
                    mountingRetries -= 1;
                } else {
                    console.error('Could not mount the route.');
                }
            }
        }

        function mountRoutes() {
            m.route(rootEl, '/', {
                '/': Wrap(isUserProfile ? c.root.UsersShow : c.root.ProjectsHome, { menuTransparency: true, footerBig: true, absoluteHome: isUserProfile }),
                '/explore': Wrap(c.root.ProjectsExplore, { menuTransparency: true, footerBig: true }),
                '/start': Wrap(c.root.Start, { menuTransparency: true, footerBig: true }),
                '/start-sub': Wrap(c.root.SubProjectNew, { menuTransparency: false }),
                '/projects/:project_id/contributions/new': Wrap(c.root.ProjectsContribution),
                '/projects/:project_id/contributions/fallback_create': Wrap(c.root.ProjectsContribution),
                '/projects/:project_id/contributions/:contribution_id/edit': Wrap(c.root.ProjectsPayment, { menuShort: true }),
                '/projects/:project_id/subscriptions/start': Wrap(c.root.ProjectsSubscriptionContribution, { menuShort: true, footerBig: false }),
                '/projects/:project_id/subscriptions/checkout': Wrap(c.root.ProjectsSubscriptionCheckout, { menuShort: true, footerBig: false }),
                '/projects/:project_id/subscriptions/thank_you': Wrap(c.root.ProjectsSubscriptionThankYou, { menuShort: true, footerBig: false }),
                [urlWithLocale('/projects/:project_id/contributions/new')]: Wrap(c.root.ProjectsContribution),
                [urlWithLocale('/projects/:project_id/contributions/:contribution_id/edit')]: Wrap(c.root.ProjectsPayment, { menuShort: true }),
                [urlWithLocale('/projects/:project_id/subscriptions/start')]: Wrap(c.root.ProjectsSubscriptionContribution, { menuShort: true, footerBig: false }),
                [urlWithLocale('/projects/:project_id/subscriptions/checkout')]: Wrap(c.root.ProjectsSubscriptionCheckout, { menuShort: true, footerBig: false }),
                [urlWithLocale('/projects/subscriptions/thank_you')]: Wrap(c.root.ProjectsSubscriptionThankYou, { menuShort: true, footerBig: false }),
                '/en': Wrap(c.root.ProjectsHome, { menuTransparency: true, footerBig: true }),
                '/pt': Wrap(c.root.ProjectsHome, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/flexible_projects')]: Wrap(c.root.ProjectsHome, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/projects')]: Wrap(c.root.ProjectsHome, { menuTransparency: true, footerBig: true }),
                '/projects': Wrap(c.root.ProjectsHome, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/explore')]: Wrap(c.root.ProjectsExplore, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/start')]: Wrap(c.root.Start, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/projects/:project_id/contributions/:contribution_id')]: Wrap(c.root.ThankYou, { menuTransparency: false, footerBig: false }),
                '/projects/:project_id/contributions/:contribution_id': Wrap(c.root.ThankYou, { menuTransparency: false, footerBig: false }),
                '/projects/:project_id/insights': Wrap(c.root.Insights, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/projects/:project_id/insights')]: Wrap(c.root.Insights, { menuTransparency: false, footerBig: false }),
                '/projects/:project_id/coming-soon': Wrap(c.root.ComingSoon, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/projects/:project_id/coming-soon')]: Wrap(c.root.ComingSoon, { menuTransparency: false, footerBig: false }),
                '/projects/:project_id/contributions_report': Wrap(c.root.ProjectsContributionReport, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/projects/:project_id/contributions_report')]: Wrap(c.root.ProjectsContributionReport, {
                    menuTransparency: false,
                    footerBig: false,
                }),
                '/projects/:project_id/subscriptions_report': Wrap(c.root.ProjectsSubscriptionReport, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/projects/:project_id/subscriptions_report')]: Wrap(c.root.ProjectsSubscriptionReport, {
                    menuTransparency: false,
                    footerBig: false,
                }),
                '/projects/:project_id/subscriptions_report_download': Wrap(c.root.ProjectsSubscriptionReportDownload, {
                    menuTransparency: false,
                    footerBig: false,
                }),
                [urlWithLocale('/projects/:project_id/subscriptions_report_download')]: Wrap(c.root.ProjectsSubscriptionReportDownload, {
                    menuTransparency: false,
                    footerBig: false,
                }),
                '/projects/:project_id/surveys': Wrap(c.root.Surveys, { menuTransparency: false, footerBig: false, menuShort: true }),
                '/projects/:project_id/fiscal': Wrap(c.root.ProjectsFiscal, { menuTransparency: false, footerBig: false, menuShort: true }),
                '/projects/:project_id/project_fiscal': Wrap(c.root.ProjectFiscals, { menuTransparency: false, footerBig: false, menuShort: true }),
                '/projects/:project_id/posts': Wrap(c.root.Posts, { menuTransparency: false, footerBig: false }),
                '/projects/:project_id/posts/:post_id': Wrap(c.root.ProjectShow, { menuTransparency: false, footerBig: true }),
                [urlWithLocale('/projects/:project_id/posts')]: Wrap(c.root.Posts, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/projects/:project_id/posts/:post_id')]: Wrap(c.root.ProjectShow, { menuTransparency: false, footerBig: true }),
                '/projects/:project_id': Wrap(c.root.ProjectShow, { menuTransparency: false, footerBig: false }),
                '/users/:user_id': Wrap(c.root.UsersShow, { menuTransparency: true, footerBig: false }),
                [urlWithLocale('/users/:user_id')]: Wrap(c.root.UsersShow, { menuTransparency: true, footerBig: false }),
                '/contributions/:contribution_id/surveys/:survey_id': Wrap(c.root.SurveysShow, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/contributions/:contribution_id/surveys/:survey_id')]: Wrap(c.root.SurveysShow, { menuTransparency: false, footerBig: false }),
                '/users/:user_id/edit': Wrap(c.root.UsersEdit, { menuTransparency: true, footerBig: false }),
                [urlWithLocale('/users/:user_id/edit')]: Wrap(c.root.UsersEdit, { menuTransparency: true, footerBig: false }),
                '/projects/:project_id/edit': Wrap(c.root.ProjectEdit, { menuTransparency: false, hideFooter: true, menuShort: true }),
                [urlWithLocale('/projects/:project_id/edit')]: Wrap(c.root.ProjectEdit, { menuTransparency: false, hideFooter: true, menuShort: true }),
                '/projects/:project_id/rewards/:reward_id/surveys/new': Wrap(c.root.SurveyCreate, { menuTransparency: false, hideFooter: true, menuShort: true }),
                [urlWithLocale('/follow-fb-friends')]: Wrap(c.root.FollowFoundFriends, { menuTransparency: false, footerBig: false }),
                '/follow-fb-friends': Wrap(c.root.FollowFoundFriends, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/:project')]: Wrap(c.root.ProjectShow, { menuTransparency: false, footerBig: false }),
                '/:project': Wrap(c.root.ProjectShow, { menuTransparency: false, footerBig: false }),
                [urlWithLocale('/team')]: Wrap(c.root.Team, { menuTransparency: true, footerBig: true }),
                '/team': Wrap(c.root.Team, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/jobs')]: Wrap(c.root.Jobs, { menuTransparency: true, footerBig: true }),
                '/jobs': Wrap(c.root.Jobs, { menuTransparency: true, footerBig: true }),
                '/press': Wrap(c.root.Press, { menuTransparency: true, footerBig: true }),
                [urlWithLocale('/press')]: Wrap(c.root.Press, { menuTransparency: true, footerBig: true }),

                [urlWithLocale('/projects/:project_id/publish')]: Wrap(c.root.Publish, { menuTransparency: false, hideFooter: true, menuShort: true }),
                ['/projects/:project_id/publish']: Wrap(c.root.Publish, { menuTransparency: false, hideFooter: true, menuShort: true }),
                [urlWithLocale('/projects/:project_id/publish-by-steps')]: Wrap(c.root.ProjectsPublishBySteps, { menuTransparency: false, hideFooter: true, menuShort: true }),
                ['/projects/:project_id/publish-by-steps']: Wrap(c.root.ProjectsPublishBySteps, { menuTransparency: false, hideFooter: true, menuShort: true }),
            });
        }
    }
})();
