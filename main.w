bring cloud; 
bring ex; 
bring math;

bring "./logs-api.w" as logsApi;

// Is this useful? How can this interact with other constructs?
let domain = new cloud.Domain(
  domainName: "wing.loganfarr.com"
);

// Should be able to define custom domain 
let logs = new logsApi.LogsApi();

// need to set env vars somehow
let website = new cloud.Website(
  path: "./public",
  domain: domain
);