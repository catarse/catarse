var apiMeta = document.getElementById("api-host");
postgrest.init(apiMeta.getAttribute('content'), {method: "GET", url: "/api_token"});

