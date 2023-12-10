{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gcc
    libcxx
    llvmPackages.libcxxClang
    gnumake42
    openssl
    pkg-config
  ];
}
