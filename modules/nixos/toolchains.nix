sysCtx @ {pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gcc
    libcxx
    llvmPackages.libcxxClang
    gnumake42
  ];
}
