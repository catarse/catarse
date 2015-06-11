app.AdminContributions_filter.vm = (function(){
  var permalink = m.prop("");


  function filter(){
    alert("I will filter this!");
    return false;
  }

  return {
    permalink: permalink,
    filter: filter
  }
})();