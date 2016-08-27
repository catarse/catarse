//= require mithril/mithril.js
//= require underscore
//= require mithril-postgrest
//= require moment
//= require replace-diacritics
//= require chartjs
//= require i18n/translations
//= require api/init
//= require catarse.js/dist/catarse.js
//= require_self

(function(m, c, Chart){
  //Chart.defaults.global.responsive = true;
  Chart.defaults.global.responsive = false;
  Chart.defaults.Line.pointHitDetectionRadius = 0;
  Chart.defaults.global.scaleFontFamily = "proxima-nova";

  I18n.defaultLocale = "pt";
  I18n.locale = "pt";

  var adminRoot = document.getElementById('new-admin');

  if(adminRoot){
    m.route.mode = 'hash';

    m.route(adminRoot, '/', {
      '/': m.component(c.root.AdminContributions, {root: adminRoot}),
      '/users': m.component(c.root.AdminUsers)
    });
  }

  var app = document.getElementById('application');

  var wrap = function(component, customAttr) {
      return {
        controller: function() {
            var attr = customAttr,
                projectParam = m.route.param('project_id'),
                projectUserIdParam = m.route.param('project_user_id'),
                rewardIdParam = m.route.param('reward_id'),
                filterParam = m.route.param('filter');
            
            var addToAttr = function(newAttr) {
                attr = _.extend({}, newAttr, attr);
            };

            if(projectParam) {
                addToAttr({project_id: projectParam});
            }

            if(projectUserIdParam) {
                addToAttr({project_user_id: projectUserIdParam});
            }

            if(rewardIdParam) {
                addToAttr({reward_id: rewardIdParam});
            }

            if(filterParam) {
                addToAttr({filter: filterParam});
            }

            var body = document.getElementsByTagName('body')[0];
            
            body.className = 'body-project closed';
            

            return {
                attr: attr
            };
        },
        view: function(ctrl){
            return m('#app', [
                m.component(c.root.Menu, ctrl.attr),
                m.component(component, ctrl.attr),
                m.component(c.root.Footer, ctrl.attr)
            ]);
        }
      };
  };

  if(app){
      var rootEl = app;
    
      m.route.mode = 'pathname';
      
      m.route(rootEl, '/', {
          '/': wrap(c.root.ProjectsHome, {menuTransparency: true, footerBig: true}),
          '/explore': wrap(c.root.ProjectsExplore, {menuTransparency: true, footerBig: true}),
          '/start': wrap(c.root.Start, {menuTransparency: true, footerBig: true}),
          // '/projects/:project_id/contribution': wrap(c.root.ProjectsReward),
          // '/projects/:project_id/payment': wrap(c.root.ProjectsPayment),
          // '/contribution': wrap(c.root.ProjectsPayment),
          '/pt': wrap(c.root.ProjectsHome, {menuTransparency: true, footerBig: true}),
          '/pt/explore': wrap(c.root.ProjectsExplore, {menuTransparency: true, footerBig: true}),
          '/pt/start': wrap(c.root.Start, {menuTransparency: true, footerBig: true}),
          '/pt/:project': wrap(c.root.ProjectsShow, {menuTransparency: false, footerBig: false}),
          '/:project': wrap(c.root.ProjectsShow, {menuTransparency: false, footerBig: false})
      });
  }
  _.each(document.querySelectorAll('div[data-mithril]'), function(el){
    var component = c.root[el.attributes['data-mithril'].value],
        paramAttr = el.attributes['data-parameters'],
        params = paramAttr && JSON.parse(paramAttr.value);
    m.mount(el, m.component(component, _.extend({root: el}, params)));
  });
}(window.m, window.c, window.Chart));

window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};
