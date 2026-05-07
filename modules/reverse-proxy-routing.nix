{ lib }:
let
  inherit (lib)
    all
    elem
    filter
    foldl'
    hasAttr
    optionalAttrs
    optionals
    unique
    ;

  fail = message: throw "reverse-proxy-routing: ${message}";

  ensure = condition: message:
    if condition then
      true
    else
      fail message;

  isNonEmptyString = value: builtins.isString value && value != "";

  ensureField = service: field:
    ensure (hasAttr field service) "service `${service.name or "<unknown>"}` is missing required field `${field}`.";

  ensureListOfStrings = service: field:
    let
      value = service.${field};
    in
    ensure (builtins.isList value) "service `${service.name}` field `${field}` must be a list."
    && ensure (all builtins.isString value) "service `${service.name}` field `${field}` must contain only strings.";

  ensureUniqueNames =
    services:
    let
      names = map (service: service.name) services;
      duplicates =
        foldl'
          (acc: name:
            if (elem name acc.seen) then
              {
                seen = acc.seen;
                dupes = acc.dupes ++ [ name ];
              }
            else
              {
                seen = acc.seen ++ [ name ];
                dupes = acc.dupes;
              })
          {
            seen = [ ];
            dupes = [ ];
          }
          names;
    in
    ensure (duplicates.dupes == [ ]) "service names must be unique; duplicates: ${builtins.concatStringsSep ", " (unique duplicates.dupes)}.";

  validateService =
    service:
    assert ensureField service "name";
    assert ensureField service "port";
    assert ensure (isNonEmptyString service.name) "service `name` must be a non-empty string.";
    assert ensure (builtins.isInt service.port) "service `${service.name}` field `port` must be an integer.";
    assert ensure (service.port > 0 && service.port <= 65535) "service `${service.name}` has invalid port `${toString service.port}`.";
    assert (
      if hasAttr "host" service then
        ensure (isNonEmptyString service.host) "service `${service.name}` field `host` must be a non-empty string."
      else
        true
    );
    assert (
      if hasAttr "entryPoints" service then
        ensureListOfStrings service "entryPoints"
      else
        true
    );
    assert (
      if hasAttr "middlewares" service then
        ensureListOfStrings service "middlewares"
      else
        true
    );
    assert (
      if hasAttr "tls" service then
        ensure (builtins.isBool service.tls) "service `${service.name}` field `tls` must be a boolean."
      else
        true
    );
    assert (
      if hasAttr "localOnly" service then
        ensure (builtins.isBool service.localOnly) "service `${service.name}` field `localOnly` must be a boolean."
      else
        true
    );
    assert (
      if hasAttr "priority" service then
        ensure (service.priority == null || builtins.isInt service.priority) "service `${service.name}` field `priority` must be an integer or null."
      else
        true
    );
    assert (
      if hasAttr "certResolver" service then
        ensure (service.certResolver == null || isNonEmptyString service.certResolver) "service `${service.name}` field `certResolver` must be a non-empty string or null."
      else
        true
    );
    assert (
      if hasAttr "domain" service then
        ensure (service.domain == null || isNonEmptyString service.domain) "service `${service.name}` field `domain` must be a non-empty string or null."
      else
        true
    );
    assert (
      if hasAttr "subdomain" service then
        ensure (isNonEmptyString service.subdomain) "service `${service.name}` field `subdomain` must be a non-empty string."
      else
        true
    );
    assert (
      if hasAttr "pathPrefix" service then
        ensure (service.pathPrefix == null || isNonEmptyString service.pathPrefix) "service `${service.name}` field `pathPrefix` must be a non-empty string or null."
      else
        true
    );
    service;
in
rec {
  mkDomain =
    {
      baseDomain,
      name,
      subdomain ? name,
      domain ? null,
      ...
    }:
    if domain != null then domain else "${subdomain}.${baseDomain}";

  normalizeServices =
    {
      services,
      defaults ? { },
    }:
    assert ensure (builtins.isList services) "`services` must be a list.";
    assert ensure (all builtins.isAttrs services) "`services` entries must be attribute sets.";
    let
      normalized = map (service: defaults // service) services;
      validated = map validateService normalized;
    in
    assert ensureUniqueNames validated;
    validated;

  mkService =
    {
      name,
      port,
      host ? "127.0.0.1",
      ...
    }:
    {
      inherit name;
      value.loadBalancer.servers = [ { url = "http://${host}:${toString port}"; } ];
    };

  mkRouter =
    {
      baseDomain,
      name,
      subdomain ? name,
      domain ? null,
      entryPoints ? [ "websecure" ],
      tls ? true,
      certResolver ? "letsencrypt",
      priority ? null,
      middlewares ? [ ],
      localOnly ? false,
      pathPrefix ? null,
      ...
    }:
    let
      hostRule = "Host(`${mkDomain { inherit baseDomain name subdomain domain; }}`)";
      rule = if pathPrefix != null then "${hostRule} && PathPrefix(`${pathPrefix}`)" else hostRule;
      resolvedMiddlewares = unique ((optionals localOnly [ "local-only" ]) ++ middlewares);
    in
    {
      inherit name;
      value =
        {
          inherit rule;
          inherit entryPoints;
          service = name;
        }
        // optionalAttrs (resolvedMiddlewares != [ ]) { middlewares = resolvedMiddlewares; }
        // optionalAttrs tls {
          tls = if certResolver == null then { } else { inherit certResolver; };
        }
        // optionalAttrs (priority != null) { inherit priority; };
    };

  generateTraefik =
    {
      baseDomain,
      services,
      defaults ? { },
    }:
    let
      normalizedServices = normalizeServices { inherit services defaults; };
      generatedServices = builtins.listToAttrs (map mkService normalizedServices);
      generatedRouters = builtins.listToAttrs (map (service: mkRouter ({ inherit baseDomain; } // service)) normalizedServices);
    in
    {
      inherit normalizedServices generatedServices generatedRouters;
    };
}
