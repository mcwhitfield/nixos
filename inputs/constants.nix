rec {
  domain = "whitfield.one";
  adminUser = "mark";
  admin = "${adminUser}@${domain}";
  tailnet = "tail19498.ts.net";
  nixosRoot = "/etc/nixos";
}
