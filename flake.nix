{
  inputs = {
    env = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    flakelight = {
      url = "github:accelbread/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    devenv,
    flakelight,
    ...
  } @ inputs:
    flakelight ./. {
      inherit inputs;
      nixpkgs.config = {allowUnfree = true;};
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      packages = {
        devenv-up = {stdenv}: self.devShells.${stdenv.system}.default.config.procfileScript;
        devenv-test = {stdenv}: self.devShells.${stdenv.system}.default.config.test;

        yarnix-cli = {pkgs}: let
          name = "yarnix-cli";
          src = ./.;
          offlineCache = pkgs.stdenv.mkDerivation {
            name = "${name}-offline-cache";
            inherit src;

            nativeBuildInputs = with pkgs; [
              cacert
              gitMinimal
              nodejs
              yarn
            ];

            buildPhase = ''
              export HOME=$(mktemp -d)
              yarn config set enableTelemetry 0
              yarn config set cacheFolder $out
              yarn
            '';

            outputHashMode = "recursive";
            outputHash = "sha256-c2YGO/GOzcQXH7jNxYPN4uDCZD1YI8rPGWoqbkGo8qg=";
          };
        in
          pkgs.stdenv.mkDerivation {
            inherit name src;

            buildInputs = with pkgs; [
              makeWrapper
              yarn
            ];

            buildPhase = ''
              runHook preBuild
              export HOME=$(mktemp -d)
              yarn config set enableTelemetry 0
              yarn config set cacheFolder ${offlineCache}
              yarn --immutable-cache
              yarn run build
              runHook postBuild
            '';

            installPhase = with pkgs; ''
              runHook preInstall
              mkdir -p $out
              cp -R {bin,lib,node_modules,package.json} $out
              chmod +x $out/bin/*
              substituteInPlace $out/bin/${name} --replace "#!/usr/bin/env node" "#!${nodejs}/bin/node"
              runHook postInstall
            '';

            meta = with pkgs; {
              description = "Exposes Yarn logic for Nix integration";
              license = lib.licenses.mit;
              homepage = "https://github.com/FactbirdHQ/yarnix-cli";
              mainProgram = "nix-yarn-cli";
              maintainers = ["noverby"];
            };
          };
      };

      devShells.default = {pkgs}:
        devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              devenv.root = let env = builtins.fromJSON (builtins.readFile inputs.env.outPath); in env.PWD;
              packages = with pkgs.nodePackages; [
                nodejs
                yarn
              ];
            }
          ];
        };
    };
}
