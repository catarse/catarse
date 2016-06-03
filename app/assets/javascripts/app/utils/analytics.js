var CatarseAnalytics = window.CatarseAnalytics = (function(){
  var _apiHost;
  var _analyticsOneTimeEventFired={};
  function _getApiHost() {
    if(_apiHost)
      return _apiHost;

    var el=document.getElementById('api-host');
    return _apiHost = el && el.getAttribute('content');
  }

  function _event(eventObj, fn) {
    if (eventObj) {
      try {
        var project = eventObj.project,
            user = eventObj.user;
        var dataProject = project&&project.id ? {
          project: {
            id: project.id,
            category_id: project.category_id,
            state: project.address && project.address.state_acronym,
            city: project.address && project.address.city
          }
        } : null;
        var dataUser = user&&user.user_id ? {
          user: {
            id: user.user_id,
            contributions: user.contributions,
            published_projects: user.published_projects
          }
        } : null;//TODO
        var data = _.extend({},eventObj.extraData,dataProject,dataUser);
        var location = window.location;
        var domain = location.origin || (location.protocol + '//' + location.hostname);
        var ga = window.ga;//o ga tem q ser verificado aqui pq pode não existir na criaçaõ do DOM
        var gaTracker = ga && ga.getAll && !_.isEmpty(ga.getAll()) ? _.first(ga.getAll()) : null;

        try {
          var sendData = {event: _.extend({},data, {
            category: eventObj.cat,
            action: eventObj.act,
            label: eventObj.lbl,
            value: eventObj.val,
            request: {
              referrer: document.referrer||undefined,
              protocol: location.protocol.substr(0,location.protocol.length-1),
              domain: domain,
              url: location.href.substr(domain.length)
            },
            ga: gaTracker ? {
              clientId: gaTracker.get('clientId')
            } : null
          })};

          $.ajax({
              type: "POST",
              url: getApiHost()+'/rpc/track',
              // The key needs to match your method's input parameter (case-sensitive).
              data: JSON.stringify(sendData),
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function(data){
                console.log('[h.analyticsEvent] /track ok', data);
              },
              failure: function(errMsg) {
                  console.error('[h.analyticsEvent] error:', e);
              }
          });
        } catch(e) {
          console.error('[CatarseAnalytics.event] error:', e);
        }

        if(typeof ga==='function') {
          //https://developers.google.com/analytics/devguides/collection/analyticsjs/sending-hits#the_send_method
          ga('send', 'event', eventObj.cat, eventObj.act, eventObj.lbl, eventObj.val, {
            nonInteraction: eventObj.nonInteraction!==false,//default é true,e só será false se, e somente se, esse parametro for definido como false
            transport: 'beacon'
          });
        }
      } catch(e) {
        console.error('[CatarseAnalytics.event] error:',e);
      }
    }
    fn && fn();
  }

  return {
    event: _event,
    oneTimeEvent: function(eventObj, fn) {
        if (!eventObj) {
            return fn;
        }
        try {
          var eventKey = _.compact([eventObj.cat,eventObj.act]).join('_');
          if (!eventKey) {
              throw new Error('Should inform cat or act');
          }
          if (!_analyticsOneTimeEventFired[eventKey]) {
              //console.log('oneTimeEvent',eventKey);
              _analyticsOneTimeEventFired[eventKey] = true;
              _event(eventObj, fn);
          }
        } catch(e) {
          console.error('[CatarseAnalytics.oneTimeEvent] error:',e);
        }
    },
  };
})();
