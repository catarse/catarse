//= require mithril
//= require underscore
//= require mithril.postgrest
//= require moment
//= require replace-diacritics
//= require api/init
//= require catarse.js/dist/catarse.js
//= require_self

(function(m, c){
  var adminRoot = document.getElementById('new-admin'),
      teamRoot = document.getElementById('team-root'),
      projectInsightsRoot = document.getElementById('project-insights-root');

  if(adminRoot){
    m.mount(adminRoot, c.admin.Contributions);
  }

  if(teamRoot){
    m.mount(teamRoot, c.pages.Team);
  }

  if(projectInsightsRoot){
    m.mount(projectInsightsRoot, m.component(c.admin.ProjectInsights, {root: projectInsightsRoot}));
  }
}(window.m, window.c));

window.toggleMenu = function(){
  var userMenu = document.getElementById("user-menu-dropdown");
  userMenu.classList.toggle('w--open');
};

