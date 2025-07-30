_: {
  packages.mkYarnWrapper = {writeShellScriptBin}: {
    nodejs,
    yarnRelease,
    env,
  }:
    writeShellScriptBin "yarn" ''
      ${env}

      ${nodejs}/bin/node ${yarnRelease} "$@"
    '';
}
