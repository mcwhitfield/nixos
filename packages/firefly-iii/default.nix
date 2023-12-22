{
  pkgs,
  firefly,
  ...
}: let
  php = pkgs.php83;
in
  php.buildComposerProject (finalAttrs: {
    pname = "firefly-iii";
    version = "1.0.0";
    src = firefly;

    php =
      php.buildEnv {
      };
  })
  // pkgs.writeShellApplication {
    name = "firefly-iii";
    runtimeInputs = with pkgs; [bash coreutils php83 php83Packages.composer];
    text = builtins.readFile ./entrypoint.sh;
  }
