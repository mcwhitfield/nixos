let
  # All the below is just to automatically assign owners to ssh keys with a naming scheme like:
  # ./ssh-user-label => {user = {label = <pubKey>}}
  # Pure eval in this file, so gotta do it by hand.
  inherit (builtins) attrNames attrValues baseNameOf concatLists elemAt filter groupBy map;
  inherit (builtins) listToAttrs mapAttrs match readDir readFile replaceStrings;

  secretsFiles = attrNames (readDir ./secrets);
  secretsMatching = patt: let
    tries = map (f: match patt (baseNameOf f)) secretsFiles;
  in
    filter (gs: !(isNull gs)) tries;

  pubkeyMatches = secretsMatching "ssh-([^-]*)-(.*)\.pub";
  userOrHost = groups: elemAt groups 0;
  label = groups: elemAt groups 1;
  readKey = groups: let
    content = readFile ./secrets/ssh-${userOrHost groups}-${label groups}.pub;
  in
    replaceStrings ["\n"] [""] content;
  perOwner = groupBy userOrHost pubkeyMatches;
  keys = mapAttrs (_: groups: map readKey groups) perOwner;

  hosts = {
    inherit (keys) turvy gitlab;
  };
  allHosts = concatLists (attrValues hosts);
  users = {
    inherit (keys) mark;
  };
  allUsers = concatLists (attrValues users);
  allKeys = allHosts ++ allUsers;

  privKeys = let
    matches = secretsMatching "^ssh-([^-]*)-([^-.]*)$";
    mkKv = groups: let
      owner = userOrHost groups;
      ownerKeys = keys.${owner};
    in {
      name = "secrets/ssh-${owner}-${label groups}";
      value = {publicKeys = ownerKeys;};
    };
  in
    listToAttrs (map mkKv matches);
in
  privKeys
  // {
    "secrets/firefly-iii-app".publicKeys = allKeys;
    "secrets/firefly-iii-db".publicKeys = allKeys;
    "secrets/firefly-iii-importer".publicKeys = allKeys;
    "secrets/gitlab-db".publicKeys = keys.gitlab;
    "secrets/gitlab-db-pass".publicKeys = keys.gitlab;
    "secrets/gitlab-jws".publicKeys = keys.gitlab;
    "secrets/gitlab-otp".publicKeys = keys.gitlab;
    "secrets/gitlab-root-pass".publicKeys = keys.gitlab;
    "secrets/gitlab-secret".publicKeys = keys.gitlab;
  }
