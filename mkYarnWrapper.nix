_: {
  packages.mkYarnWrapper = {writeShellScriptBin}: {
    nodejs,
    yarnSrc,
    env,
  }:
    writeShellScriptBin "yarn" ''
      ${env}

      ${nodejs}/bin/node ${yarnSrc} "$@"
    '';
}
