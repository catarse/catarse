var apiMeta = document.getElementById("api-host");
m.postgrest.init(apiMeta.getAttribute('content'), {method: "GET", url: "/api_token"});

