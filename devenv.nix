{pkgs, ...}: {
  packages = with pkgs.nodePackages; [
    nodejs
    yarn
  ];
}
