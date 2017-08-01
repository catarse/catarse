//= require mithril/mithril.min.js
//= require jquery
//= require select
//= require underscore/underscore-min.js
//= require mithril-postgrest
//= require moment/min/moment.min.js
//= require lib/replace-diacritics
//= require chart.js/Chart.min.js
//= require i18n/translations
//= require ../analytics
//= require api/init
//= require catarse.js/dist/catarse.js
//= require_self

(function(m, c, Chart, analytics){
  Chart.defaults.global.responsive = true;
  Chart.defaults.global.responsive = false;
  Chart.defaults.global.scaleFontFamily = "proxima-nova";

  I18n.defaultLocale = "pt";
  I18n.locale = "pt";

  var adminRoot = document.getElementById('new-admin');

  if(adminRoot){
      var adminWrap = function(component, customAttr) {
          return {
              controller: function() {
                  var attr = customAttr;

                  return {
                      attr: attr
                  };
              },
              view: function(ctrl) {
                  return m('#app', [
                      m.component(c.root.Menu, ctrl.attr),
                      m.component(component, ctrl.attr),
                      (ctrl.attr.hideFooter ? '' : m.component(c.root.Footer, ctrl.attr))
                  ]);
              }
          };
      };
    m.route.mode = 'hash';

    m.route(adminRoot, '/', {
        '/': adminWrap(c.root.AdminContributions, {root: adminRoot, menuTransparency: false, hideFooter: true}),
        '/users': adminWrap(c.root.AdminUsers, { menuTransparency: false, hideFooter: true }),
        '/balance-transfers': adminWrap(c.root.AdminBalanceTranfers, { menuTransparency: false, hideFooter: true })
    });
  }

    var app = document.getElementById('application'),
        body = document.getElementsByTagName('body')[0];
    var firstRun = true;//Indica se é a primeira vez q executa um controller.

  var wrap = function(component, customAttr) {
      return {
        controller: function() {
            if(firstRun) {
                firstRun=false;
            } else {//só roda se nao for firstRun
                try {
                    analytics.pageView(false);
                } catch(e) {console.error(e);}
            }
            var parameters = app.getAttribute('data-parameters') ? JSON.parse(app.getAttribute('data-parameters')) : {};
            var attr = customAttr,
                projectParam = m.route.param('project_id') || parameters.project_id,
                projectUserIdParam = m.route.param('project_user_id') || parameters.user_id || parameters.project_user_id,
                userParam = m.route.param('user_id') || app.getAttribute('data-userid') || parameters.user_id,
                rewardIdParam = m.route.param('reward_id'),
                surveyIdParam = m.route.param('survey_id'),
                filterParam = m.route.param('filter'),
                thankYouParam = app && JSON.parse(app.getAttribute('data-contribution'));

            var addToAttr = function(newAttr) {
                attr = _.extend({}, newAttr, attr);
            };

            if(projectParam) {
                addToAttr({project_id: projectParam});
            }

            if(userParam) {
                addToAttr({user_id: userParam});
            }

            if(projectUserIdParam) {
                addToAttr({project_user_id: projectUserIdParam});
            }

            if(surveyIdParam) {
                addToAttr({survey_id: surveyIdParam});
            }

            if(rewardIdParam) {
                addToAttr({reward_id: rewardIdParam});
            }

            if(filterParam) {
                addToAttr({filter: filterParam});
            }

            if(thankYouParam) {
                addToAttr({contribution: thankYouParam});
            }

            if(window.localStorage && (window.localStorage.getItem('globalVideoLanding') !== 'true')) {
                addToAttr({withAlert: false});
            }

            if(document.getElementById('fixed-alert')) {
                addToAttr({withFixedAlert: true});
            }

            body.className = 'body-project closed';


            return {
                attr: attr
            };
        },
        view: function(ctrl){
            return m('#app', [
                m.component(c.root.Menu, ctrl.attr),
                m.component(c.root.CheckEmail, ctrl.attr),
                m.component(component, ctrl.attr),
                (ctrl.attr.hideFooter ? '' : m.component(c.root.Footer, ctrl.attr))
            ]);
        }
      };
  };

  if(app){
      var rootEl = app,
          isUserProfile = body.getAttribute('data-controller-name') == 'users' && body.getAttribute('data-action') == 'show' && app.getAttribute('data-hassubdomain') == 'true';

      m.route.mode = 'pathname';

      m.route(rootEl, '/', {
          '/': wrap(( isUserProfile ? c.root.UsersShow : c.root.ProjectsHome), {menuTransparency: true, footerBig: true, absoluteHome: isUserProfile}),
          '/explore': wrap(c.root.ProjectsExplore, {menuTransparency: true, footerBig: true}),
          '/start': wrap(c.root.Start, {menuTransparency: true, footerBig: true}),
          '/projects/:project_id/contributions/new': wrap(c.root.ProjectsContribution),
          '/projects/:project_id/contributions/:contribution_id/edit': wrap(c.root.ProjectsPayment, {menuShort: true}),
          '/pt/projects/:project_id/contributions/new': wrap(c.root.ProjectsContribution),
          '/pt/projects/:project_id/contributions/:contribution_id/edit': wrap(c.root.ProjectsPayment, {menuShort: true}),
          '/pt': wrap(c.root.ProjectsHome, {menuTransparency: true, footerBig: true}),
          '/pt/flexible_projects': wrap(c.root.ProjectsHome, {menuTransparency: true, footerBig: true}),
          '/pt/projects': wrap(c.root.ProjectsHome, {menuTransparency: true, footerBig: true}),
          '/projects': wrap(c.root.ProjectsHome, {menuTransparency: true, footerBig: true}),
          '/pt/explore': wrap(c.root.ProjectsExplore, {menuTransparency: true, footerBig: true}),
          '/pt/start': wrap(c.root.Start, {menuTransparency: true, footerBig: true}),
          '/pt/projects/:project_id/contributions/:contribution_id': wrap(c.root.ThankYou, {menuTransparency: false, footerBig: false}),
          '/projects/:project_id/contributions/:contribution_id': wrap(c.root.ThankYou, {menuTransparency: false, footerBig: false}),
          '/pt/:project': wrap(c.root.ProjectsShow, {menuTransparency: false, footerBig: false}),
          '/projects/:project_id/insights': wrap(c.root.Insights, {menuTransparency: false, footerBig: false}),
          '/pt/projects/:project_id/insights': wrap(c.root.Insights, {menuTransparency: false, footerBig: false}),
          '/projects/:project_id/contributions_report': wrap(c.root.ProjectsContributionReport, {menuTransparency: false, footerBig: false}),
          '/pt/projects/:project_id/contributions_report': wrap(c.root.ProjectsContributionReport, {menuTransparency: false, footerBig: false}),
          '/projects/:project_id/posts': wrap(c.root.Posts, {menuTransparency: false, footerBig: false}),
          '/projects/:project_id/surveys': wrap(c.root.Surveys, {menuTransparency: false, footerBig: false, menuShort: true}),
          '/pt/projects/:project_id/posts': wrap(c.root.Posts, {menuTransparency: false, footerBig: false}),
          '/projects/:project_id': wrap(c.root.ProjectsShow, {menuTransparency: false, footerBig: false}),
          '/users/:user_id': wrap(c.root.UsersShow, {menuTransparency: true, footerBig: false}),
          '/pt/users/:user_id': wrap(c.root.UsersShow, {menuTransparency: true, footerBig: false}),
          '/contributions/:contribution_id/surveys/:survey_id': wrap(c.root.SurveysShow, {menuTransparency: false, footerBig: false}),
          '/pt/contributions/:contribution_id/surveys/:survey_id': wrap(c.root.SurveysShow, {menuTransparency: false, footerBig: false}),
          '/users/:user_id/edit': wrap(c.root.UsersEdit, {menuTransparency: true, footerBig: false}),
          '/pt/users/:user_id/edit': wrap(c.root.UsersEdit, {menuTransparency: true, footerBig: false}),
          '/projects/:project_id/edit': wrap(c.root.ProjectEdit, {menuTransparency: false, hideFooter: true, menuShort: true}),
          '/pt/projects/:project_id/edit': wrap(c.root.ProjectEdit, {menuTransparency: false, hideFooter: true, menuShort: true}),
          '/projects/:project_id/rewards/:reward_id/surveys/new': wrap(c.root.SurveyCreate, {menuTransparency: false, hideFooter: true, menuShort: true}),
          '/:project': wrap(c.root.ProjectsShow, {menuTransparency: false, footerBig: false}),
          '/pt/follow-fb-friends': wrap(c.root.FollowFoundFriends, {menuTransparency: false, footerBig: false}),
          '/follow-fb-friends': wrap(c.root.FollowFoundFriends, {menuTransparency: false, footerBig: false}),
          '/pt/team': wrap(c.root.Team, {menuTransparency: true, footerBig: true}),
          '/team': wrap(c.root.Team, {menuTransparency: true, footerBig: true}),
          '/pt/jobs': wrap(c.root.Jobs, {menuTransparency: true, footerBig: true}),
          '/jobs': wrap(c.root.Jobs, {menuTransparency: true, footerBig: true})
      });
  }
  _.each(document.querySelectorAll('div[data-mithril]'), function(el){
    var component = c.root[el.attributes['data-mithril'].value],
        paramAttr = el.attributes['data-parameters'],
        params = paramAttr && JSON.parse(paramAttr.value);
    m.mount(el, m.component(component, _.extend({root: el}, params)));
  });
}(window.m, window.c, window.Chart, window.CatarseAnalytics));

window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};
