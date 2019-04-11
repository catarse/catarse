//evitamos criar duas vezes...
//tem q ser não dependente de outros codigos
window.CatarseAnalytics = window.CatarseAnalytics || (function(){
    /*!
   * cookie-monster - a simple cookie library
   * v0.3.0
   * https://github.com/jgallen23/cookie-monster
   * copyright Greg Allen 2014
   * MIT License
  */
  var monster={set:function(name,value,days,path,secure,domain){var date=new Date(),expires='',type=typeof(value),valueToUse='',secureFlag='';path=path||"/";if(days){date.setTime(date.getTime()+(days*24*60*60*1000));expires="; expires="+date.toUTCString();}if(type==="object"&&type!=="undefined"){if(!("JSON"in window))throw"Bummer, your browser doesn't support JSON parsing.";valueToUse=encodeURIComponent(JSON.stringify({v:value}));}else{valueToUse=encodeURIComponent(value);}if(secure){secureFlag="; secure";}domain=domain?"; domain="+encodeURIComponent(domain):"";document.cookie=name+"="+valueToUse+expires+"; path="+path+secureFlag+domain;},get:function(name){var nameEQ=name+"=",ca=document.cookie.split(';'),value='',firstChar='',parsed={};for(var i=0;i<ca.length;i++){var c=ca[i];while(c.charAt(0)==' ')c=c.substring(1,c.length);if(c.indexOf(nameEQ)===0){value=decodeURIComponent(c.substring(nameEQ.length,c.length));firstChar=value.substring(0,1);if(firstChar=="{"){try{parsed=JSON.parse(value);if("v"in parsed)return parsed.v;}catch(e){return value;}}if(value=="undefined")return undefined;return value;}}return null;},remove:function(name){this.set(name,"",-1);},increment:function(name,days){var value=this.get(name)||0;this.set(name,(parseInt(value,10)+1),days);},decrement:function(name,days){var value=this.get(name)||0;this.set(name,(parseInt(value,10)-1),days);}};
  var ajax = (function(){
    //based on https://raw.githubusercontent.com/yanatan16/nanoajax/v0.2.4/index.js
    function getRequest() {
      if (window.XMLHttpRequest)
        return new window.XMLHttpRequest;
      else
        try { return new window.ActiveXObject("MSXML2.XMLHTTP.3.0"); } catch(e) {}
      throw new Error('no xmlhttp request able to be created')
    }

    function setDefault(obj, key, value) {
      obj[key] = obj[key] || value
    }

    return function (params, callback) {
      if (typeof params == 'string') params = {url: params}
      var headers = params.headers || {}
        , body = params.body
        , method = params.method || (body ? 'POST' : 'GET')
        , withCredentials = params.withCredentials || false

      var req = getRequest();

      // has no effect in IE
      // has no effect for same-origin requests
      // has no effect in CORS if user has disabled 3rd party cookies
      req.withCredentials = withCredentials

      req.onreadystatechange = function () {
        if (req.readyState == 4)
          callback(req.status, req.responseText, req)
      }

      if (body) {
        setDefault(headers, 'X-Requested-With', 'XMLHttpRequest')
        setDefault(headers, 'Content-Type', "application/json; charset=utf-8")//'application/x-www-form-urlencoded')
      }

      req.open(method, params.url, true)

      for (var field in headers)
        req.setRequestHeader(field, headers[field])

      req.send(body)
    }
  })();

  var base_url = 'www.catarse.me', cookie_url='.catarse.me';

  var ctrse_sid=(function(cookie){
    var sid=cookie.get('ctrse_sid');
    if(!sid) {
      /*based on https://github.com/makeable/uuid-v4.js*/
      var UUID=function(){for(var dec2hex=[],i=0;15>=i;i++)dec2hex[i]=i.toString(16);return function(){for(var uuid="",i=1;36>=i;i++)uuid+=9===i||14===i||19===i||24===i?"-":15===i?4:20===i?dec2hex[4*Math.random()|8]:dec2hex[15*Math.random()|0];return uuid}}();
      sid=UUID();
    }
    cookie.set('ctrse_sid',sid,180,'/',true,cookie_url);
    return sid;
  })(monster);

  var _apiHost,_user,_project;
  var _analyticsOneTimeEventFired={};
  function _actualRequest() {
    var location = window.location;
    var domain = location.origin || (location.protocol + '//' + location.hostname);
    return {
      referrer: document.referrer||undefined,
      url: location.href,
      protocol: location.protocol.substr(0,location.protocol.length-1),
      hostname: location.hostname,
      domain: domain,
      pathname: location.pathname || location.href.substr(domain.length).replace(/[\?\#].*$/,''),
      userAgent: typeof navigator!=='undefined' ? navigator.userAgent : undefined,
      hash: location.hash.replace(/^\#/,''),
      query: (function parseParams() {
          if(location.search) {
            try {
              return location.search.replace(/^\?/,'').split('&').reduce(function (params, param) {
                  var paramSplit = param.split('=').map(function (value) {
                      return decodeURIComponent(value.replace('+', ' '));
                  });
                  params[paramSplit[0]] = paramSplit[1];
                  return params;
              }, {});
            } catch(e) {
              return location.search;
            }
          }
      })()
    };
  };

  var _firstPageView=true;
  function _origin(_request) {
    var _date=new Date();
    try {
      var o = JSON.parse(monster.get('ctrse_origin')||null) || {createdAt: _date,updatedAt: _date};
    } catch(e) {
      o = {createdAt: _date,updatedAt: _date};
    }

    var query=_request.query;
    var origin_has_utm=['domain','campaign','source','medium','content','term'].some(function(p){return !!o[p]});
    var query_has_utm=query && ['utm_campaign','utm_source','utm_medium','utm_content','utm_term'].some(function(p){return !!query[p]});
    var expired = !o._time || (_date.getTime()-o._time)>10*60*1000/*10 min*/;

    var fromSite= (!_firstPageView)//se não é a primeira vez q passa aqui, só pode ser fromSite.
            || (_request.referrer && new RegExp(base_url).test(_request.referrer));
    if(fromSite) {
      //Só pega o ultimo ref. Não atualiza utms...
      if(query && query.ref && o.ref!=query.ref) {
        if(!origin_has_utm) o.domain=base_url;
        o.ref = query.ref;
        o.updatedAt = _date;
      }
    } else if(/*!fromSite && */ _request.referrer || expired) {
      var m=_request.referrer && _request.referrer.match(/https?:\/\/([^\/\?#]+)/);
      var refDomain=(m && m[1]) || undefined;
      //se, e somente se, tem algum utm na query...
      if(query_has_utm) {//então, substitui todos, mesmo os q nao tem, pois são um conjunto de informações...
        o.domain  =refDomain;
        o.campaign=query.utm_campaign;
        o.source  =query.utm_source;
        o.medium  =query.utm_medium;
        o.content =query.utm_content;
        o.term    =query.utm_term;
        o.updatedAt=_date;
      } else if (refDomain && !origin_has_utm) {//se tem refDomain e não tem no origin algum utm ou domain anterior...
        o.domain   = refDomain;
        o.updatedAt= _date;
      }

      if(!o.campaign && query && query.ref) {
        //nesse caso, como veio de outro dominio, sem utm params, mas com ref, assumimos q esse ref é um campaign.
        o.campaign = query.ref;
        o.updatedAt= _date;
      }
    }
    //fazemos o _time aqui por causa da verificação acima !o._time, indicando q foi criado agora.
    o._time=_date.getTime();
    monster.set('ctrse_origin',JSON.stringify(o),180,'/',true,cookie_url);
    return o;
  };

  //Metodos semelhantes ao modulo "h"
  function _getApiHost() {
    if(window.CatarseAnalyticsURL)
      return window.CatarseAnalyticsURL;
    if(_apiHost)
      return _apiHost;

    var el=document.getElementById('api-moments-host');
    _apiHost = (el && el.getAttribute('content'));
    if(_apiHost)
      _apiHost=_apiHost+'/rpc/track';
    return _apiHost;
  }
  function _getUser() {
    if(_user)
      return _user;

    var body = document.getElementsByTagName('body'),
        data = body && body[0] && body[0].getAttribute('data-user');
    if(data) {
      try {
        return _user=JSON.parse(data);
      } catch(e) {
        console.error('[CatarseAnalytics._getUser] error parsing data '+JSON.stringify(data), e);
      }
    }
  }
  function _getProject() {
    if(_project)
      return _project;
    var el = document.getElementById('project-show-root')||document.getElementById('project-header'),//pode não existir
        data = el && (el.getAttribute('data-parameters')||el.getAttribute('data-stats'));
    if(data) {
      try {
        return  _project=JSON.parse(data);
      } catch(e) {
        console.error('[CatarseAnalytics._getProject] error parsing data '+JSON.stringify(data), e);
      }
    }//else return undefined
  }

  function _event(eventObj, fn, ignoreGA) {
    if (eventObj) {
      try {
        var project = eventObj.project||_getProject(),
            user = eventObj.user||_getUser();
        var ga = window.ga;//o ga tem q ser verificado aqui pq pode não existir na criaçaõ do DOM
        var gaTracker = (typeof ga==='function' && ga.getAll && ga.getAll() && ga.getAll()[0]) || null;
        ignoreGA = ignoreGA || typeof ga!=='function';

        var _request = _actualRequest();
        var data = eventObj.extraData&&typeof eventObj.extraData==='object' ? JSON.parse(JSON.stringify(eventObj.extraData)) : {};
        data.ctrse_sid=ctrse_sid;
        data.origin=_origin(_request);
        data.category=eventObj.cat;
        data.action=eventObj.act;
        data.label=eventObj.lbl;
        data.value=eventObj.val;
        data.request=_request;
        if(user&&user.user_id) {
          data.user={
            id: user.user_id,
            contributions: user.contributions,
            published_projects: user.published_projects
          };
        }
        if(project&&(project.id||project.project_id)) {
          data.project={
            id: project.id||project.project_id,
            user_id: project.user_id||project.project_user_id,
            category_id: project.category_id,
            state: project.address && project.address.state_acronym,
            city: project.address && project.address.city
          };
        }
        if(gaTracker) {
          data.ga={clientId: gaTracker.get('clientId')};
        }

        try {
          var apiUrl=_getApiHost();
          if(apiUrl) {
            var sendData = {
              event: data
            };

            ajax({
                url: apiUrl,
                // The key needs to match your method's input parameter (case-sensitive).
                body: JSON.stringify(sendData),
                headers: {
                  'Content-Type': "application/json; charset=utf-8"
                }
            }, function(status, responseText, req){
              if(status!==200)
                console.error(status,responseText,req);
            });
          }
        } catch(e) {
          console.error('[CatarseAnalytics.event] error:', e);
        }

        if(!ignoreGA && typeof ga!='undefined') {
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

  /*function _lastOrigin() {
    var origin=localStorage
    if(documnet.referrer && /https?:\/\/[^\/]*catarse\.me/.test(document.referrer)) {

    }
  }*/
  var pvto;
  function _pageView(firstPageView) {
    if(!firstPageView)
      _firstPageView=false;
    
    pvto&&clearTimeout(pvto);
    pvto=setTimeout(function() {
      _event({cat:'navigation',act:'pageview',lbl:location.pathname}, null, true);//ignoraGa pq vai mandar abaixo
      //on first page view, GA will to this for us
      if(!firstPageView && typeof ga!='undefined') {
        ga('set','page',location.pathname);
        ga('send', 'pageview', location.pathname);
      }
    });
  }
  _pageView(true);//Na primeira vez q carrega a página, o pageview do GA será enviado na pagina mesmo.

  function _checkout(transactionId, prodName, sku, category, price, fee) {
    try {
      if(typeof ga==='function') {
        ga('ecommerce:addTransaction', {
          'id': transactionId,                     // Transaction ID. Required.
          //'affiliation': 'Acme Clothing',   // Affiliation or store name.
          'revenue': price,               // Grand Total.
          //'shipping': ,                  // Shipping.
          'tax': fee,                     // Tax.  Nossa porcentagem
          'current': 'BRL'
        });
        ga('ecommerce:addItem', {
          'id': transactionId,                     // Transaction ID. Required.
          'name': prodName,    // Product name. Required.
          'sku': sku,                 // SKU/code.
          'category': category,         // Category or variation.
          'price': price,                 // Unit price.
          'quantity': '1'                   // Quantity.
        });
        ga('ecommerce:send');
      }
    } catch(e) {
      console.error('[CatarseAnalytics.checkout]',e);
    }
  }

  return {
    origin: function(){
      //Evita de passar outro request
      return _origin(_actualRequest());
    },
    event: _event,
    pageView: _pageView,
    oneTimeEvent: function(eventObj, fn) {
        if (!eventObj) {
            return fn;
        }
        try {
          if (!eventObj.cat && !eventObj.act) {
            throw new Error('Should inform cat or act');
          }
          var eventKey = eventObj.cat && eventObj.act ? eventObj.cat+'_'+eventObj.act : (eventObj.cat || eventObj.act);
          if (!_analyticsOneTimeEventFired[eventKey]) {
              //console.log('oneTimeEvent',eventKey);
              _analyticsOneTimeEventFired[eventKey] = true;
              _event(eventObj, fn);
          }
        } catch(e) {
          console.error('[CatarseAnalytics.oneTimeEvent] error:',e);
        }
    },
    checkout: _checkout
  };
})();
