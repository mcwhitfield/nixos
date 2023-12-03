{pkgs, ...} @ sysCtx: {
  environment.systemPackages = with pkgs; [
    gcc
    libcxx
    llvmPackages.libcxxClang
    gnumake42
  ];
}
