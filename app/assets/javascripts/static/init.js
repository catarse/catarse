var teamRoot = document.getElementById("team-root");
m.postgrest.init(teamRoot.getAttribute('data-api'), {method: "GET", url: "/api_token"});
