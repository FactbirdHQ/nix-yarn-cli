_: {
  packages.yarnix-cli = {pkgs}: let
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
        mainProgram = name;
        maintainers = ["noverby"];
      };
    };
}
