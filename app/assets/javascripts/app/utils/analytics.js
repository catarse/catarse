var CatarseAnalytics = window.CatarseAnalytics = {
    event: function(eventObj, fn) {
      try {
        var ga = window.ga;//o ga tem q ser verificado aqui pq pode não existir na criaçaõ do DOM
        if(eventObj && ga) {
          //https://developers.google.com/analytics/devguides/collection/analyticsjs/sending-hits#the_send_method
          ga('send', 'event', eventObj.cat, eventObj.act, eventObj.lbl, eventObj.val, {
            nonInteraction: eventObj.nonInteraction!==false,//default é true,e só será false se, e somente se, esse parametro for definido como false
            transport: 'beacon'
          });
        }
      } catch(e) {
        console.error('[CatarseAnalytics.event] error:',e);
      }
      fn && fn();
    },
    _analyticsOneTimeEventFired: {},
    oneTimeEvent: function(eventObj, fn) {
        if (!eventObj) {
            return fn;
        }

        var eventKey = _.compact([eventObj.cat,eventObj.act]).join('_');
        if (!eventKey) {
            throw new Error('Should inform cat or act');
        }
        var _this=this;
        return function() {
            if (!_analyticsOneTimeEventFired[eventKey]) {
                //console.log('oneTimeEvent',eventKey);
                _analyticsOneTimeEventFired[eventKey] = true;
                _this.event(eventObj, fn);
            }
        };
    },
};
