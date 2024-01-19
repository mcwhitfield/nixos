let
  # All the below is just to automatically assign owners to ssh keys with a naming scheme like:
  # ./ssh-user-label => {user = {label = <pubKey>}}
  # Pure eval in this file, so gotta do it by hand.
  inherit (builtins) attrNames baseNameOf concatLists elemAt filter groupBy map;
  inherit (builtins) listToAttrs mapAttrs match readDir readFile replaceStrings;

  secretsFiles = attrNames (readDir ./secrets);
  secretsMatching = patt: let
    tries = map (f: match patt (baseNameOf f)) secretsFiles;
  in
    filter (gs: !(isNull gs)) tries;

  pubkeyMatches = secretsMatching "ssh-(user|host)-(.*)-(initrd-)?([^-]*)\.pub";
  ownerType = groups: elemAt groups 0;
  userOrHost = groups: elemAt groups 1;
  initrd = groups: let
    maybeInitrd = elemAt groups 2;
  in
    if (isNull maybeInitrd)
    then ""
    else maybeInitrd;
  label = groups: elemAt groups 3;
  readKey = groups: let
    original = "ssh-${ownerType groups}-${userOrHost groups}-${initrd groups}${label groups}";
    content = readFile ./secrets/${original}.pub;
  in
    replaceStrings ["\n"] [""] content;
  perOwner = groupBy userOrHost pubkeyMatches;
  keys = mapAttrs (_: groups: map readKey groups) perOwner;

  privKeys = let
    mkKv = groups: let
      owner = userOrHost groups;
    in {
      name = "secrets/ssh-${ownerType groups}-${owner}-${label groups}";
      value.publicKeys = keys.${owner};
    };
  in
    listToAttrs (map mkKv pubkeyMatches);

  adminKeys = concatLists [
    keys.mark
  ];
  addAdminAccess = secret: {publicKeys}: {publicKeys = publicKeys ++ adminKeys;};
in
  mapAttrs addAdminAccess (
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
  )
