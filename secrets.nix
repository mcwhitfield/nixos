let
  inherit (builtins) attrValues;
  systems = {
    turvy = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKPRQPEh/V/ughlQqpiyBQSq7ERnW1yrPmk987ruRGN";
  };
  users = {
    mark = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGE/eUXX4kr+hhZWBT5MEpJKt2oed9Fg3+EWEB10+ev";
  };
  keys = systems // users;
in {
  "secrets/firefly-iii".publicKeys = keys;
  "secrets/mark-ssh-0".publicKeys = attrValues systems ++ [users.mark];
  "secrets/mark-password".publicKeys = attrValues systems ++ [users.mark];
}
