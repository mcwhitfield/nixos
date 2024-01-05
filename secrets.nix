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

  pubkeyMatches = secretsMatching "ssh-(user|host)-(.*)-([^-]*)\.pub";
  ownerType = groups: elemAt groups 0;
  userOrHost = groups: elemAt groups 1;
  label = groups: elemAt groups 2;
  readKey = groups: let
    content = readFile ./secrets/ssh-${ownerType groups}-${userOrHost groups}-${label groups}.pub;
  in
    replaceStrings ["\n"] [""] content;
  perOwner = groupBy userOrHost pubkeyMatches;
  keys = mapAttrs (_: groups: map readKey groups) perOwner;
  devKeys = {inherit (keys) mark;};

  privKeys = let
    mkKv = groups: let
      owner = userOrHost groups;
      otherReaders =
        if (ownerType groups) == "user"
        then []
        else concatLists (attrValues devKeys);
    in {
      name = "secrets/ssh-${ownerType groups}-${owner}-${label groups}";
      value = {publicKeys = keys.${owner} ++ otherReaders;};
    };
  in
    listToAttrs (map mkKv pubkeyMatches);
in
  privKeys
  // {
    "secrets/firefly-iii-app".publicKeys = keys.firefly-iii;
    "secrets/firefly-iii-db".publicKeys = keys.firefly-iii;
    "secrets/firefly-iii-importer".publicKeys = keys.firefly-iii;
    "secrets/gitlab-db".publicKeys = keys.gitlab;
    "secrets/gitlab-db-pass".publicKeys = keys.gitlab;
    "secrets/gitlab-jws".publicKeys = keys.gitlab;
    "secrets/gitlab-otp".publicKeys = keys.gitlab;
    "secrets/gitlab-root-pass".publicKeys = keys.gitlab;
    "secrets/gitlab-secret".publicKeys = keys.gitlab;
    "secrets/namecheap-creds".publicKeys = with keys;
      concatLists [
        firefly-iii
        gitlab
        vaultwarden
      ];
  }
