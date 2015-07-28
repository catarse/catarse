var adminRoot = document.getElementById("new-admin");

m.postgrest.init(adminRoot.getAttribute('data-api'), {method: "GET", url: "/api_token"});
